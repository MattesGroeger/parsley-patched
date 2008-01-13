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
 
package org.spicefactory.parsley.context.tree.core.enum {

/**
 * Enumeration for all available autowire modes.
 * Autowiring enables the factory to automatically set property values based on 
 * the type or the name of the property.
 * 
 * @author Jens Halm
 */
public class AutowireMode {

	/**
	 * Constant for disabling any autowiring.
	 */
	public static const OFF:AutowireMode = new AutowireMode("OFF");
	
	/**
	 * Constant for autowiring by type. In this mode the type of the property
	 * is used to find an object in the <code>ApplicationContext</code> that is an
	 * instance or subtype of the type of the property.
	 */
	public static const BY_TYPE:AutowireMode = new AutowireMode("BY_TYPE");
	
	/**
	 * Constant for autowiring by name. In this mode the name of the property
	 * is used to find an object in the <code>ApplicationContext</code> with a matching id.
	 */
	public static const BY_NAME:AutowireMode = new AutowireMode("BY_NAME");
	
	
	private var _name:String;
	
	/**
	 * @private
	 */
	function AutowireMode (name:String) {
		_name = name;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return _name;
	}

}

}