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
 
package org.spicefactory.parsley.context.tree.values {

/**
 * Represents a configuration artifact that has a single object reference as its child. 
 * 
 * @author Jens Halm
 */
public class ReferenceHolderConfig {
	
	private var _valueConfig:ValueConfig;

	
	/**
	 * Creates a new instance.
	 */
	function ReferenceHolderConfig () {
		
	}
	
	public function setChildConfig (config:ValueConfig) : void {
		_valueConfig = config;
	}
	
	/**
	 * Returns the referenced object this instance wraps.
	 * 
	 * @return the referenced object this instance wraps
	 */
	public function getObject () : Object {
		return _valueConfig.value;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "" + _valueConfig; // cannot call toString directly for interface types
	}	
	
}

}