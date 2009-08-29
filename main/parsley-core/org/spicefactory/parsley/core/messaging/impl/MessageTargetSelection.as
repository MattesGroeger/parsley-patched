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
import org.spicefactory.parsley.core.messaging.MessageTarget;

import flash.events.Event;
import flash.utils.Dictionary;

/**
 * A cached selection of targets for a particular message type.
 * Will be used by the default MessageRouter implementation as a performance optimization.
 * 
 * @author Jens Halm
 */
public class MessageTargetSelection {
	
	
	private var _messageType:ClassInfo;
	private var _selectorProperty:Property;
	
	private var _targetsWithSelector:Array = new Array();
	private var _interceptorsWithSelector:Array = new Array();
	
	private var _targetsWithoutSelector:Array = new Array();
	private var _interceptorsWithoutSelector:Array = new Array();
	
	private var _targetSelectorMap:Dictionary = new Dictionary();
	private var _interceptorSelectorMap:Dictionary = new Dictionary();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of the message
	 */
	function MessageTargetSelection (type:ClassInfo) {
		_messageType = type;
		for each (var p:Property in type.getProperties()) {
			if (p.getMetadata(Selector).length > 0) {
				if (_selectorProperty == null) {
					_selectorProperty = p;
				}
				else {
					throw new ContextError("Class " + type.name + " contains more than one Selector metadata tag");
				}
			}
		}
		if (_selectorProperty == null && _messageType.isType(Event)) {
			_selectorProperty = _messageType.getProperty("type");
		}
	}
	
	/**
	 * The type of the message.
	 */
	public function get messageType () : ClassInfo {
		return _messageType;
	}
	
	/**
	 * Returns the value of the selector property of the specified message instance.
	 * 
	 * @param message the message instance
	 * @return the value of the selector property of the specified message instance
	 */
	public function getSelectorValue (message:Object) : * {
		if (_selectorProperty != null) {
			return _selectorProperty.getValue(message);
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
		var targets:Array = null;
		if (_targetSelectorMap[selectorValue] != undefined) {
			targets = _targetSelectorMap[selectorValue];
		}
		else {
			targets = new Array();
			_targetSelectorMap[selectorValue] = targets;
			for each (var target:MessageTarget in _targetsWithSelector) {
				if (target.selector == selectorValue) {
					targets.push(target);
				}
			}
		}
		return targets.concat(_targetsWithoutSelector);
	}
	
	/**
	 * Returns all interceptors that match for the specified selector value.
	 * 
	 * @param selectorValue the value of the selector property
	 * @return all interceptors that match for the specified selector value
	 */	
	public function getInterceptors (selectorValue:*) : Array {
		var interceptors:Array = null;
		if (_interceptorSelectorMap[selectorValue] != undefined) {
			interceptors = _interceptorSelectorMap[selectorValue];
		}
		else {
			interceptors = new Array();
			_interceptorSelectorMap[selectorValue] = interceptors;
			for each (var target:MessageTarget in _interceptorsWithSelector) {
				if (target.selector == selectorValue) {
					interceptors.push(target);
				}
			}
		}
		return interceptors.concat(_interceptorsWithoutSelector);
	}
	
	/**
	 * Adds a message target (handler, binding, interceptor) to this selection.
	 * 
	 * @param target the target to add
	 */
	public function addTarget (target:MessageTarget) : void {
		var collection:Array = (target.interceptor) ?
				((target.selector == undefined) ? _interceptorsWithoutSelector : _interceptorsWithSelector)
				: ((target.selector == undefined) ? _targetsWithoutSelector : _targetsWithSelector);
		collection.push(target);
	}
}

}
