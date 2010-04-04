/*
 * Copyright 2009 the original author or authors.
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
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.errors.ContextError;

import flash.events.Event;
import flash.utils.Dictionary;

/**
 * A cached selection of receivers for a particular message type and its subtypes.
 * Will be used by the default MessageRouter implementation as a performance optimization.
 * 
 * @author Jens Halm
 */
public class MessageReceiverSelectionCache {
	
	
	private var _messageType:ClassInfo;
	private var collections:Array;
	private var selectorProperty:Property;
	private var selectorMap:Dictionary = new Dictionary();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of the message
	 * @param collections the collections of receivers applicable for this message type and its subtypes
	 */
	function MessageReceiverSelectionCache (type:ClassInfo, collections:Array) {
		_messageType = type;
		this.collections = collections;
		for each (var collection:MessageReceiverCollection in collections) {
			addListener(collection);
		}
		for each (var p:Property in type.getProperties()) {
			if (p.getMetadata(Selector).length > 0) {
				if (selectorProperty == null) {
					selectorProperty = p;
				}
				else {
					throw new ContextError("Class " + type.name + " contains more than one Selector metadata tag");
				}
			}
		}
		if (selectorProperty == null && _messageType.isType(Event)) {
			selectorProperty = _messageType.getProperty("type");
		}
	}
	
	/**
	 * Returns the value of the selector property of the specified message instance.
	 * 
	 * @param message the message instance
	 * @return the value of the selector property of the specified message instance
	 */
	public function getSelectorValue (message:Object) : * {
		if (selectorProperty != null) {
			return selectorProperty.getValue(message);
		}
		else {
			return message.toString();
		}
	}
	
	/**
	 * Checks whether the specified new collection matches the message type of this cache and adds
	 * it in that case.
	 * 
	 * @param collection the new collection to check
	 */
	public function checkNewCollection (collection:MessageReceiverCollection) : void {
		if (_messageType.isType(collection.messageType)) {
			collections.push(collection);
			selectorMap = new Dictionary();
			addListener(collection);
		}
	}
	
	private function addListener (collection:MessageReceiverCollection) : void {
		collection.addEventListener(Event.CHANGE, collectionChanged);
	}
	
	private function collectionChanged (event:Event) : void {
		selectorMap = new Dictionary();
	}
	
	/**
	 * Returns all receivers of a particular kind that match for the specified selector value.
	 * 
	 * @param kind the kind of receiver to fetch
	 * @param selectorValue the value of the selector property
	 * @return all receivers of a particular kind that match for the specified selector value
	 */	
	public function getReceivers (kind:MessageReceiverKind, selectorValue:*) : Array {
		var receivers:Array = null;
		if (selectorMap[kind] != undefined && selectorMap[kind][selectorValue] != undefined) {
			return selectorMap[kind][selectorValue];
		}
		else {
			receivers = new Array();
			for each (var collection:MessageReceiverCollection in collections) {
				var subset:Array = collection.getReceivers(kind, selectorValue);
				if (subset.length > 0) {
					receivers = receivers.concat(subset);
				}
			}
			var map:Dictionary = selectorMap[kind];
			if (map == null) {
				map = new Dictionary();
				selectorMap[kind] = map;
			}
			map[selectorValue] = receivers;
			return receivers;
		}
	}
	
	/**
	 * Indicates whether this cache has first level targets (MessageTarget, CommandTarget or MessageInterceptor)
	 * for the specified selector. If no first level target exists for a particular message
	 * the creation of a MessageProcessor instance can be skipped since second level targets (CommandObservers 
	 * and MessageErrorHandlers) can only be triggered due to the outcome of a first level target.
	 * 
	 * @param selectorValue the value of the selector property
	 * @return true if this cache has first level targets for the specified kind and selector
	 */
	public function hasFirstLevelTargets (selectorValue:*) : Boolean {
		return (getReceivers(MessageReceiverKind.INTERCEPTOR, selectorValue).length > 0
			|| getReceivers(MessageReceiverKind.TARGET, selectorValue).length > 0);
	}
	
	/**
	 * Releases this selection cache in case it is no longer used.
	 * Usually only called by the framework when there is no Context left that uses the
	 * ApplicationDomain the message type of this cache belongs to.
	 */
	public function release () : void {
		selectorMap = null;
		for each (var collection:MessageReceiverCollection in collections) {
			collection.removeEventListener(Event.CHANGE, collectionChanged);
		}
	}


}
}
