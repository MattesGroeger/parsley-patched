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

package org.spicefactory.parsley.core.messaging.receiver.impl {
import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class Providers {
	
	
	public static function forInstance (instance:Object, domain:ApplicationDomain = null) : TargetInstanceProvider {
		return new SimpleInstanceProvider(instance, domain);
	}
	
	
	// forObjectProvider
	
	// forDynamicObject
	
}
}

import org.spicefactory.lib.reflect.ClassInfo;

import flash.system.ApplicationDomain;
import org.spicefactory.parsley.core.messaging.receiver.impl.TargetInstanceProvider;

class SimpleInstanceProvider implements TargetInstanceProvider {
	
	
	private var _instance:Object;
	private var _type:ClassInfo;
	
	
	function SimpleInstanceProvider (instance:Object, domain:ApplicationDomain = null) {
		_instance = instance;
		_type = ClassInfo.forInstance(instance, domain);
	}
	
	public function get instance () : Object {
		return _instance;
	}
	
	public function get type () : ClassInfo {
		return _type;
	}
	
	
}
