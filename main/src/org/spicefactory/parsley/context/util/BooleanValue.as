/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.util {

/**
 * Represents a boolean value. Needed in some cases where null is also a valid value for a boolean type. 
 * 
 * @author Jens Halm
 */	
public class BooleanValue {

	private var _value:Boolean;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param value the boolean value to wrap
	 */
	public function BooleanValue (value:Boolean) {
		_value = value;
	}
	
	/**
	 * The wrapped boolean value.
	 */
	public function get value () : Boolean {
		return _value;
	}
		
}
	
}