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
import org.spicefactory.lib.util.Command;

/**
 * Interface to be implemented by configuration classes which represent values which
 * can be bound to properties of other instances.
 * 
 * @author Jens Halm
 */
public interface BoundValueConfig {

	/**
	 * Binds the value of this configuration artifact to the specified property.
	 * The returned Command instance should represent the action to execute to unbind
	 * the value. This Command will usually automatically be invoked when the ApplicationContext
	 * that created this binding gets destroyed.
	 * 
	 * @param target the owner of the property
	 * @param property the name of the property
	 * @return the Command to execute to unbind the value
	 */
	function bind (target:Object, property:String) : Command ;
		
}

}