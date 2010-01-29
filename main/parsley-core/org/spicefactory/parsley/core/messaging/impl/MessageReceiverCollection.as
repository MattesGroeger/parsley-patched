/*
 * Copyright 2010 the original author or authors.
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
import flash.events.Event;
import flash.events.EventDispatcher;
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;
import flash.utils.Dictionary;

/**
 * Dispatched when a message receiver was added to or removed from the collection.
 * 
 * @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 * A collection of message receivers for a particular message type.
 * 
 * @author Jens Halm
 */
public class MessageReceiverCollection extends EventDispatcher {
	
	
	private var receivers:Dictionary = new Dictionary();
	
	private var _messageType:Class;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param messageType the type of the message
	 */
	function MessageReceiverCollection (messageType:Class) {
		_messageType = messageType;
	}
	
	
	/**
	 * The type of message receivers in this collection are interested in.
	 */
	public function get messageType ():Class {
		return _messageType;
	}
	
	/**
	 * Returns all receivers of a particular kind that match for the specified selector value.
	 * 
	 * @param kind the kind of receiver to fetch
	 * @param selectorValue the value of the selector property
	 * @return all receivers of a particular kind that match for the specified selector value
	 */	
	public function getReceivers (kind:MessageReceiverKind, selectorValue:*) : Array {
		var array:Array = receivers[kind] as Array;
		if (array == null) {
			return [];
		}
		var filtered:Array = new Array();
		for each (var receiver:MessageReceiver in array) {
			if (receiver.selector == undefined || receiver.selector == selectorValue) {
				filtered.push(receiver);
			}
		}
		return filtered;
	}
	
	/**
	 * Adds a receiver to this collection.
	 * 
	 * @param kind the kind of the receiver
	 * @param receiver the receiver to add
	 */
	public function addReceiver (kind:MessageReceiverKind, receiver:MessageReceiver) : void {
		var array:Array = receivers[kind] as Array;
		if (array == null) {
			array = new Array();
			receivers[kind] = array;
		}
		array.push(receiver);
		dispatchEvent(new Event(Event.CHANGE));
	}

	/**
	 * Removes a receiver from this collection.
	 * 
	 * @param kind the kind of the receiver
	 * @param receiver the receiver to remove
	 */
	public function removeReceiver (kind:MessageReceiverKind, receiver:MessageReceiver) : void {
		var array:Array = receivers[kind] as Array;
		if (array == null) {
			return;
		}
		ArrayUtil.remove(array, receiver);
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	
}
}
