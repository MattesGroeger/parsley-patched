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
 
package org.spicefactory.parsley.context.tree.core {
import org.spicefactory.lib.errors.AbstractMethodError;	

/**
 * Abstract base class for all types of factory method configuration.
 * 
 * @author Jens Halm
 */
public class FactoryMethodConfig  
		extends AbstractMethodConfig {
	
	
	private var _method:String;
	
	
	public override function set methodName (value:String) : void {
		_method = value;
	}
	
	/**
	 * The name of the factory method.
	 */
	public override function get methodName () : String {
		if (_method != null) {
			return _method;
		} else {
			return getAttributeValue("method");
		}
	}
	
	/**
	 * Invokes the factory method and returns the new instance.
	 * 
	 * @return the new instance created by the factory method
	 */
	public function createInstance () : Object {
		var factory:Object = getFactory();
		return invoke(factory);
	}
	
	/**
	 * Returns the target instance to invoke the factory method on.
	 * 
	 * @return the target instance to invoke the factory method on
	 */
	protected function getFactory () : Object {
		throw new AbstractMethodError();
	}
}

}