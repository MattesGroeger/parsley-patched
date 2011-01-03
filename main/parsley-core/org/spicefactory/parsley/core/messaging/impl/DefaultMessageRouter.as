/*
 * Copyright 2008-2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.MessageReceiverCache;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.command.impl.DefaultCommandManager;
import org.spicefactory.parsley.core.messaging.command.impl.DefaultCommandObserverProcessor;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.state.manager.GlobalDomainManager;

import flash.errors.IllegalOperationError;

/**
 * Default implementation of the MessageRouter interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageRouter implements MessageRouter {
	
	
	private static const log:Logger = LogContext.getLogger(DefaultMessageRouter);
	
	
	private var _receivers:DefaultMessageReceiverRegistry;
	private var _commandManager:DefaultCommandManager;
	
	private var isLifecylceEventRouter:Boolean;
	private var settings:MessageSettings;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param settings the settings this router should use
	 */
	function DefaultMessageRouter () {
		_commandManager = new DefaultCommandManager();
	}

	
	/**
	 * @inheritDoc
	 */
	public function init (settings:MessageSettings, domainManager:GlobalDomainManager, isLifecylceEventRouter:Boolean) : void {
		this.isLifecylceEventRouter = isLifecylceEventRouter;
		_receivers = new DefaultMessageReceiverRegistry(domainManager);
		for each (var handler:MessageErrorHandler in settings.errorHandlers) {
			_receivers.addErrorHandler(handler);
		}
		this.settings = settings;
	}

	/**
	 * @inheritDoc
	 */
	public function getReceiverCache (type:ClassInfo) : MessageReceiverCache {
		return _receivers.getSelectionCache(type);
	}
	
	private function getEffectiveCache (message:Message, 
			receiverKind:MessageReceiverKind, joinCaches:Array) : MessageReceiverCache {
		var cache:MessageReceiverCache = getReceiverCache(message.type);
		if (joinCaches) {
			cache = new MergedMessageReceiverCache(joinCaches.concat([cache]));
		}
		return (cache.getReceivers(receiverKind, message.selector).length > 0) ? cache : null;
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Message, receiverCaches:Array = null) : void {
		if (!message.selector) {
			message.selector = _receivers.getSelectionCache(message.type).getSelectorValue(message.instance);
		}
		var cache:MessageReceiverCache = getEffectiveCache(message, MessageReceiverKind.TARGET, receiverCaches);
		if (!cache) {
			if (!isLifecylceEventRouter && log.isDebugEnabled()) {
				log.debug("Discarding message '{0}': no matching receiver", message.instance);
			}
			return;
		}
		var processor:DefaultMessageProcessor = new DefaultMessageProcessor(message, cache, settings);
		processor.start();
	}	
	
	/**
	 * @inheritDoc
	 */
	public function observeCommand (command:Command, observerCaches:Array = null) : void {
		if (isLifecylceEventRouter) {
			throw new IllegalOperationError("Lifecycle router does not support command observers");
		}
		_commandManager.addActiveCommand(command);
		if (observerCaches) {
			command.addStatusHandler(handleCommand, observerCaches);
			handleCommand(command, observerCaches, CommandStatus.EXECUTE);
		}
	}
	
	private function handleCommand (command:Command, joinCaches:Array, status:CommandStatus = null) : void {	
		if (!status) status = command.status;
		var cache:MessageReceiverCache = getEffectiveCache(command.message, MessageReceiverKind.forCommandStatus(status), joinCaches);
		if (!cache && !command.hasObserver(status)) {
			if (log.isDebugEnabled()) {
				log.debug("Discarding command status {0} for message '{1}': no matching observer", status, command.message.instance);
			}
			return;
		}
		var processor:DefaultCommandObserverProcessor 
				= new DefaultCommandObserverProcessor(command, cache, settings, status);
		processor.start();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get receivers () : MessageReceiverRegistry {
		return _receivers;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get commandManager () : CommandManager {
		return _commandManager;
	}
}
}

import org.spicefactory.parsley.core.messaging.MessageReceiverCache;
import org.spicefactory.parsley.core.messaging.impl.MessageReceiverKind;

class MergedMessageReceiverCache implements MessageReceiverCache {

	private var caches:Array;
	
	function MergedMessageReceiverCache (caches:Array) {
		this.caches = caches;
	}

	public function getReceivers (kind:MessageReceiverKind, selector:*) : Array {
		var receivers:Array = new Array();
		for each (var cache:MessageReceiverCache in caches) {
			var merge:Array = cache.getReceivers(kind, selector);
			if (merge.length > 0) {
				receivers = (receivers.length > 0) ? receivers.concat(merge) : merge;
			}
		}
		return receivers;
	}
	
}

