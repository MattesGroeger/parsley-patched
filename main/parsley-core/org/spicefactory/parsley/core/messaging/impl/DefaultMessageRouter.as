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
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the MessageRouter interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageRouter implements MessageRouter {
	
	
	private var context:Context;
	
	private var targets:Array = new Array();
	private var interceptors:Array = new Array();
	private var errorHandlers:Array = new Array();
	
	private var receiverSelectionCache:Dictionary = new Dictionary();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the associated context instance
	 */
	function DefaultMessageRouter (context:Context) {
		this.context = context;
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, domain:ApplicationDomain = null, selector:* = undefined) : void {
		if (domain == null) domain = ClassInfo.currentDomain;
		var messageType:ClassInfo = ClassInfo.forInstance(message, domain);
		var processor:MessageProcessor = new DefaultMessageProcessor(message, messageType, this);
		processor.proceed();
	}	
	
	/**
	 * @private
	 */
	internal function getReceiverSelection (messageType:ClassInfo) : MessageReceiverSelection {
		var receiverSelection:MessageReceiverSelection =
				receiverSelectionCache[messageType.getClass()] as MessageReceiverSelection;
		if (receiverSelection == null) {
			receiverSelection = new MessageReceiverSelection(messageType, getReceivers(interceptors, messageType),
					getReceivers(targets, messageType), getReceivers(errorHandlers, messageType));
			receiverSelectionCache[messageType.getClass()] = receiverSelection;
		}
		return receiverSelection;
	}
	
	private function getReceivers (receivers:Array, messageType:ClassInfo) : MessageReceiverCollection {
		var collection:MessageReceiverCollection = new MessageReceiverCollection();
		for each (var receiver:MessageReceiver in receivers) {
			if (messageType.isType(receiver.messageType.getClass())) {
				collection.addReceiver(receiver);
			}
		}
		return collection;
	}
	

	/**
	 * @inheritDoc
	 */
	public function addTarget (target:MessageTarget) : void {
		clearCache();
		targets.push(target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeTarget (target:MessageTarget) : void {
		if (ArrayUtil.remove(targets, target)) {
			clearCache();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addInterceptor (interceptor:MessageInterceptor) : void {
		clearCache();
		interceptors.push(interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeInterceptor (target:MessageInterceptor) : void {
		if (ArrayUtil.remove(interceptors, target)) {
			clearCache();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addErrorHandler (interceptor:MessageErrorHandler) : void {
		clearCache();
		errorHandlers.push(interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeErrorHandler (target:MessageErrorHandler) : void {
		if (ArrayUtil.remove(errorHandlers, target)) {
			clearCache();
		}
	}


	private function checkState () : void {
		// TODO - should be in proxy
	}

	private function clearCache () : void {
		receiverSelectionCache = new Dictionary();
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		receiverSelectionCache = null;
		targets = null;
		interceptors = null;
		errorHandlers = null;
	}
	
	
}
}

