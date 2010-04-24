/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.core.lifecycle {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.ObjectDefinition;

/**
 * Responsible for managing the lifecycle of objects based on their <code>ObjectDefinition</code>s.
 * It is used as a strategy in the builtin <code>Context</code> implementations.
 * 
 * @author Jens Halm
 */
public interface ObjectLifecycleManager {
	
	/**
	 * Instantiates a new object based on the specified ObjectDefinition.
	 * This should not include processing its configuration, like performing dependency injection or message handler registration.
	 * To allow bidirectional associations this step is deferred until <code>configureObject</code> is invoked.
	 * 
	 * @param definition the definition to create a new instance for
	 * @param context the Context the object belongs to
	 * @return the new instance
	 */
	function createObject (definition:ObjectDefinition, context:Context) : ManagedObject;	

	/**
	 * Processes the configuration for the specified object and performs dependency injection, message handler registration
	 * or invocation of methods marked with <code>[Init]</code> and similar tasks.
	 * 
	 * @param object the object to configure
	 */
	function configureObject (object:ManagedObject) : void;	

	/**
	 * Processes lifecycle listeners for the object before it will be removed from the Context.
	 * This includes invoking methods marked with <code>[Destroy]</code>.
	 * 
	 * @param object the object to process
	 */
	function destroyObject (object:ManagedObject) : void;	
	
	/**
	 * Processes lifecycle listeners for all objects created by this manager. This means that
	 * implementations have to keep track of all instances they create.
	 */
	function destroyAll () : void;
	
}

}
