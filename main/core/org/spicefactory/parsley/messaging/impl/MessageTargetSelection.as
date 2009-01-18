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

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class MessageTargetSelection {
	
	
	private var _messageType:ClassInfo;
	private var _targets:Array;
	private var _interceptors:Array;
	
	private var _selectorMap:Dictionary;
	
	
	public function get messageType () : ClassInfo {
		return _messageType;
	}
	
	public function get targets ():Array {
		return _targets;
	}
	
	public function get interceptors ():Array {
		return _interceptors;
	}
	
	public function addTarget (target:MessageTarget) : void {
		if (target.interceptor) {
			_interceptors.push(target);
		}
		else {
			_targets.push(target);
		}
	}
	
	
}

}
