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
 
package org.spicefactory.parsley.core.view.impl {

/**
 * Represents a single injection to be performed for a wired view.
 * 
 * @author Jens Halm
 */
public class ViewInjection {
	
	
	private var _property:String;
	private var _type:Class;
	private var _objectId:String;
	
	
	/**
	 * Creates a new event instance.
	 * 
	 * @param property the property to inject into
	 * @param type the type of the object to inject
	 * @param objectId te type of the object to inject
	 */
	function ViewInjection (property:String, type:Class, objectId:String = null) {
		_property = property;
		_type = type;
		_objectId = objectId;
	}

	
	/**
	 * The property to inject into.
	 */
	public function get property () : String {
		return _property;
	}
	
	/**
	 * The type of the object to inject.
	 */
	public function get type () : Class {
		return _type;
	}
	
	/**
	 * The id of the object to inject.
	 */
	public function get objectId () : String {
		return _objectId;
	}
	
	
}
}
