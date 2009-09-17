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

/**
 * A cached selection of targets for a particular message type.
 * Will be used by the default MessageRouter implementation as a performance optimization.
 * 
 * @author Jens Halm
 */
public class MessageReceiverSelection {
	
	
	private var _messageType:ClassInfo;
	private var selectorProperty:Property;
	
	private var interceptors:MessageReceiverCollection;
	private var targets:MessageReceiverCollection;
	private var errorHandlers:MessageReceiverCollection;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of the message
	 */
	function MessageReceiverSelection (type:ClassInfo, interceptors:MessageReceiverCollection,
			targets:MessageReceiverCollection, errorHandlers:MessageReceiverCollection) {
		_messageType = type;
		this.interceptors = interceptors;
		this.targets = targets;
		this.errorHandlers = errorHandlers;
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
	 * Returns all regular targets (handlers and bindings) that match for the specified selector value.
	 * 
	 * @param selectorValue the value of the selector property
	 * @return all regular targets that match for the specified selector value
	 */	
	public function getTargets (selectorValue:*) : Array {
		return targets.getReceicers(selectorValue);
	}
	
	/**
	 * Returns all interceptors that match for the specified selector value.
	 * 
	 * @param selectorValue the value of the selector property
	 * @return all interceptors that match for the specified selector value
	 */	
	public function getInterceptors (selectorValue:*) : Array {
		return interceptors.getReceicers(selectorValue);
	}
	
	/**
	 * Returns all error handlers that match for the specified selector value.
	 * 
	 * @param selectorValue the value of the selector property
	 * @return all error handlers that match for the specified selector value
	 */	
	public function getErrorHandlers (selectorValue:*) : Array {
		return errorHandlers.getReceicers(selectorValue);
	}
	

}

}
