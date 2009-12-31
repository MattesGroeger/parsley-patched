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
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.CommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

import flash.utils.Dictionary;

/**
 * Default implementation of the MessageReceiverRegistry interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageReceiverRegistry implements MessageReceiverRegistry {
	
	
	
	private var targets:Array = new Array();
	private var interceptors:Array = new Array();
	private var errorHandlers:Array = new Array();
	private var commandObservers:Dictionary = new Dictionary();
	
	private var selectionCache:Dictionary = new Dictionary();
	
	
	
	/**
	 * Returns the selection of receivers that match the specified message type.
	 * 
	 * @param messageType the message type to match against
	 * @return the selection of receivers that match the specified message type
	 */
	public function getSelection (messageType:ClassInfo) : MessageReceiverSelection {
		var receiverSelection:MessageReceiverSelection =
				selectionCache[messageType.getClass()] as MessageReceiverSelection;
		if (receiverSelection == null) {
			receiverSelection = new MessageReceiverSelection(messageType, interceptors, targets, errorHandlers, commandObservers);
			selectionCache[messageType.getClass()] = receiverSelection;
		}
		return receiverSelection;
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

	/**
	 * @inheritDoc
	 */
	public function addCommand (command:CommandTarget) : void {
		clearCache();
		targets.push(command);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeCommand (command:CommandTarget) : void {
		if (ArrayUtil.remove(targets, command)) {
			clearCache();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addCommandObserver (observer:CommandObserver) : void {
		clearCache();
		getObservers(observer.status).push(observer);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeCommandObserver (observer:CommandObserver) : void {
		if (ArrayUtil.remove(getObservers(observer.status), observer)) {
			clearCache();
		}
	}
	
	private function getObservers (status:CommandStatus) : Array {
		var key:String = status.key + "Observer";
		var observers:Array = commandObservers[key];
		if (observers == null) {
			observers = new Array();
			commandObservers[key] = observers;
		}
		return observers;
	}
	
	private function clearCache () : void {
		selectionCache = new Dictionary();
	}
	
	
}
}

