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

package org.spicefactory.parsley.core.registry.definition {
import org.spicefactory.parsley.core.registry.ObjectLifecycleListener;

/**
 * A registry for all lifecycle listeners registered for a single instance.
 * 
 * @author Jens Halm
 */
public interface LifecycleListenerRegistry {
	
	/**
	 * Adds a lifecycle listener to this registry.
	 * 
	 * @param listener the listener to add
	 * @param priority the priority (determining the order in which listeners get executed)
	 * @return this registry instance for method chaining
	 */
	function addLifecycleListener (listener:ObjectLifecycleListener, priority:int = 0) : LifecycleListenerRegistry;
	
	/**
	 * Removes the specified listener from this registry.
	 * 
	 * @listener the listener to remove
	 * @return this registry instance for method chaining
	 */
	function removeLifecycleListener (listener:ObjectLifecycleListener) : LifecycleListenerRegistry;
	
	/**
	 * Returns all listeners added to this registry sorted by priority (highest priority first).
	 * 
	 * @return all listeners added to this registry sorted by priority (highest priority first)
	 */
	function getAll () : Array;
	
}
}
