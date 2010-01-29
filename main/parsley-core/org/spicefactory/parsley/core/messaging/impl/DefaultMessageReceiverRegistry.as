/*
 * Copyright 2008-2010 the original author or authors.
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
import org.spicefactory.parsley.core.builder.impl.ReflectionCacheManager;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.CommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the MessageReceiverRegistry interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageReceiverRegistry implements MessageReceiverRegistry {
	
	
	
	private var receivers:Dictionary = new Dictionary();
	
	private var selectionCache:Dictionary = new Dictionary();
	
	
	/**
	 * Returns the selection of receivers that match the specified message type.
	 * 
	 * @param messageType the message type to match against
	 * @return the selection of receivers that match the specified message type
	 */
	public function getSelectionCache (messageType:ClassInfo) : MessageReceiverSelectionCache {
		var receiverSelection:MessageReceiverSelectionCache =
				selectionCache[messageType.getClass()] as MessageReceiverSelectionCache;
		if (receiverSelection == null) {
			var collections:Array = new Array();
			for each (var collection:MessageReceiverCollection in receivers) {
				if (messageType.isType(collection.messageType)) {
					collections.push(collection);
				}
			}
			receiverSelection = new MessageReceiverSelectionCache(messageType, collections);
			selectionCache[messageType.getClass()] = receiverSelection;
			ReflectionCacheManager.addPurgeHandler(messageType.applicationDomain, clearDomainCache, messageType.getClass());
		}
		return receiverSelection;
	}
	
	private function clearDomainCache (domain:ApplicationDomain, type:Class) : void {
		var receiverSelection:MessageReceiverSelectionCache = selectionCache[type] as MessageReceiverSelectionCache;
		receiverSelection.release();
		delete selectionCache[type];
	}
	
	
	private function addReceiver (kind:MessageReceiverKind, receiver:MessageReceiver) : void {
		var collection:MessageReceiverCollection = receivers[receiver.messageType] as MessageReceiverCollection;
		if (collection == null) {
			collection = new MessageReceiverCollection(receiver.messageType);
			receivers[receiver.messageType] = collection; 
			for each (var cache:MessageReceiverSelectionCache in selectionCache) {
				cache.checkNewCollection(collection);
			}
		}
		collection.addReceiver(kind, receiver);
	}
	
	private function removeReceiver (kind:MessageReceiverKind, receiver:MessageReceiver) : void {
		var collection:MessageReceiverCollection = receivers[receiver.messageType] as MessageReceiverCollection;
		if (collection == null) {
			return;
		}
		collection.removeReceiver(kind, receiver);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function addTarget (target:MessageTarget) : void {
		addReceiver(MessageReceiverKind.TARGET, target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeTarget (target:MessageTarget) : void {
		removeReceiver(MessageReceiverKind.TARGET, target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addInterceptor (interceptor:MessageInterceptor) : void {
		addReceiver(MessageReceiverKind.INTERCEPTOR, interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeInterceptor (interceptor:MessageInterceptor) : void {
		removeReceiver(MessageReceiverKind.INTERCEPTOR, interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addErrorHandler (errorHandler:MessageErrorHandler) : void {
		addReceiver(MessageReceiverKind.ERROR_HANDLER, errorHandler);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeErrorHandler (errorHandler:MessageErrorHandler) : void {
		removeReceiver(MessageReceiverKind.ERROR_HANDLER, errorHandler);
	}

	/**
	 * @inheritDoc
	 */
	public function addCommand (command:CommandTarget) : void {
		addReceiver(MessageReceiverKind.TARGET, command);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeCommand (command:CommandTarget) : void {
		removeReceiver(MessageReceiverKind.TARGET, command);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addCommandObserver (observer:CommandObserver) : void {
		addReceiver(MessageReceiverKind.forCommandStatus(observer.status), observer);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeCommandObserver (observer:CommandObserver) : void {
		removeReceiver(MessageReceiverKind.forCommandStatus(observer.status), observer);
	}
	
	
}
}

