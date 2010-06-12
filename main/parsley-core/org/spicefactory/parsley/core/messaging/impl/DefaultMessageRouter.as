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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.factory.MessageSettings;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.messaging.command.impl.DefaultCommandManager;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;

import flash.system.ApplicationDomain;

/**
 * Default implementation of the MessageRouter interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageRouter implements MessageRouter {
	
	
	private var _receivers:DefaultMessageReceiverRegistry;
	private var _commandManager:DefaultCommandManager;
	
	private var env:MessagingEnvironment;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param settings the settings this router should use
	 */
	function DefaultMessageRouter (settings:MessageSettings) {
		_receivers = new DefaultMessageReceiverRegistry();
		_commandManager = new DefaultCommandManager();
		env = new DefaultMessagingEnvironment(_commandManager, settings.commandFactories, settings.unhandledError);
		for each (var handler:MessageErrorHandler in settings.errorHandlers) {
			_receivers.addErrorHandler(handler);
		}
	}

	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, domain:ApplicationDomain, selector:* = undefined) : void {
		if (domain == null) domain = ClassInfo.currentDomain;
		var messageType:ClassInfo = ClassInfo.forInstance(message, domain);
		var cache:MessageReceiverSelectionCache = _receivers.getSelectionCache(messageType);
		var actualSelector:* = (selector == undefined) ? cache.getSelectorValue(message) : selector;
		if (!cache.hasFirstLevelTargets(actualSelector)) {
			return;
		}
		var processor:MessageProcessor 
				= new DefaultMessageProcessor(message, messageType, cache, actualSelector, env);
		processor.proceed();
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

import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.command.CommandFactoryRegistry;
import org.spicefactory.parsley.core.messaging.command.impl.DefaultCommandManager;
import org.spicefactory.parsley.core.messaging.impl.MessagingEnvironment;

class DefaultMessagingEnvironment implements MessagingEnvironment {


	private var _unhandledError:ErrorPolicy;
	private var commandManager:DefaultCommandManager;
	private var commandFactories:CommandFactoryRegistry;
	
	
	function DefaultMessagingEnvironment (commandManager:DefaultCommandManager, 
			commandFactories:CommandFactoryRegistry, unhandledError:ErrorPolicy) {
		this.commandManager = commandManager;
		this.commandFactories = commandFactories;
		_unhandledError = unhandledError;
	}

	
	public function getCommandFactory (type:Class) : CommandFactory {
		return commandFactories.getCommandFactory(type);
	}
	
	public function addActiveCommand (command:Command) : void {
		commandManager.addActiveCommand(command);
	}

	public function get unhandledError () : ErrorPolicy {
		return _unhandledError;
	}
	
	
}

