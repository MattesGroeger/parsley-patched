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
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractArrayValueHolderConfig;

/**
 * Abstract baes class for all types of method call configuration.
 * 
 * @author Jens Halm
 */
public class AbstractMethodConfig 
	extends AbstractArrayValueHolderConfig {
		
		
	/**
	 * Invokes the method configured by this instance and returns the result.
	 * 
	 * @param obj the target instance to invoke the method on
	 * @return the return value of the method invokation
	 */
	public function invoke (obj:Object) : * {
		var name:String = methodName;
		if (!(obj[name] is Function)) {
			throw new ConfigurationError("Unable to resolve method '" + name + "' for given target object");
		}
		return obj[name].apply(obj, getArray());
	}

	public function set methodName (name:String) : void {
		throw new AbstractMethodError();
	}
		
	/**
	 * The name of the method.
	 */
	public function get methodName () : String {
		throw new AbstractMethodError();
	}
	
	
	
}

}