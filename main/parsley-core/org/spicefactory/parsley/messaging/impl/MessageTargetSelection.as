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

package org.spicefactory.parsley.messaging.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.messaging.MessageTarget;

import flash.utils.Dictionary;

/**
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
	
	
	function MessageTargetSelection (type:ClassInfo) {
		_messageType = type;
		for each (var p:Property in type) {
			if (p.getMetadata(Selector).length > 0) {
				if (_selectorProperty == null) {
					_selectorProperty = p;
				}
				else {
					throw new ContextError("Class " + type.name + " contains more than one Selector metadata tag");
				}
			}
		}
	}
	
	
	public function get messageType () : ClassInfo {
		return _messageType;
	}
	
	public function getSelectorValue (message:Object) : * {
		if (_selectorProperty != null) {
			return _selectorProperty.getValue(message);
		}
		else {
			return message.toString();
		}
	}
	
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
	
	public function addTarget (target:MessageTarget) : void {
		var collection:Array = (target.interceptor) ?
				((target.selector === undefined) ? _interceptorsWithoutSelector : _interceptorsWithSelector)
				: ((target.selector === undefined) ? _targetsWithoutSelector : _interceptorsWithSelector);
		collection.push(target);
	}
	
	
}

}
