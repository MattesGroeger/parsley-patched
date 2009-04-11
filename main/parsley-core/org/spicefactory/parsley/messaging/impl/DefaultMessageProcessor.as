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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.messaging.MessageProcessor;
import org.spicefactory.parsley.messaging.MessageTarget;

/**
 * @author Jens Halm
 */
public class DefaultMessageProcessor implements MessageProcessor {
	
	
	private static const log:Logger = LogContext.getLogger(DefaultMessageProcessor);

	
	private var _message:Object;
	
	private var _targets:Array;
	private var _interceptors:Array;
	
	private var _currentIndex:uint = 0;
	
	
	function DefaultMessageProcessor (message:Object, targets:Array, interceptors:Array) {
		_message = message;
		_targets = targets;
		_interceptors = interceptors;
	}
	
	public function proceed () : void {
		if (_interceptors.length > _currentIndex) {
			var ic:MessageTarget = _interceptors[_currentIndex++];
			invokeMessageTarget(ic);
		}
		else {
			for each (var target:MessageTarget in _targets) {
				invokeMessageTarget(target);
			}
		}
	}
	
	private function invokeMessageTarget (target:MessageTarget) : void {
		try {
			target.handleMessage(this);
		}
		catch (e:Error) {
			log.error("Message Target threw Error", e);
		}
	}
	
	public function rewind () : void {
		_currentIndex = 0;
	}
	
	public function get message () : Object {
		return _message;
	}
	
	
}
}
