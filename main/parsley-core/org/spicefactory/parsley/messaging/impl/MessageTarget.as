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
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.messaging.LazyMessageTarget;
import org.spicefactory.parsley.messaging.MessageProcessor;

/**
 * @author Jens Halm
 */
public class MessageTarget {
	
	private var _targetType:ClassInfo;
	private var _targetInstance:Object;
	
	private var _messageType:ClassInfo;
	private var _selector:*;
	
	private var _interceptor:Boolean;
	
	function MessageTarget (targetInstance:Object, messageType:ClassInfo, selector:*, interceptor:Boolean) {
		this._targetType = (targetInstance is LazyMessageTarget) ? 
				ClassInfo.forClass(LazyMessageTarget(targetInstance).type) : ClassInfo.forInstance(targetInstance);
		this._targetInstance = targetInstance;
		this._messageType = messageType;
		this._selector = selector;
		this._interceptor = interceptor;
	}

	public function handleMessage (processor:MessageProcessor) : void {
		throw new AbstractMethodError();
	}
	
	public function get targetType ():ClassInfo {
		return _targetType;
	}
	
	public function get targetInstance ():Object {
		return _targetInstance;
	}
	
	public function get messageType ():ClassInfo {
		return _messageType;
	}
	
	public function get selector ():* {
		return _selector;
	}
	
	public function get interceptor () : Boolean {
		return _interceptor;
	}
}
}
