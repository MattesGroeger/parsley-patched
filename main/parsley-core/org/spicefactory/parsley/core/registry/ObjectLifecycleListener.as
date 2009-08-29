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

package org.spicefactory.parsley.core.registry {
import org.spicefactory.parsley.core.context.Context;

/**
 * Listener to be invoked when the associated object gets created or when it gets destroyed.
 * Implementations of this interface may be added to an <code>ObjectDefinition</code>.
 * 
 * @author Jens Halm
 */
public interface ObjectLifecycleListener {
	
	/**
	 * Method to be invoked after an instance has been created and configured, including
	 * dependency injection or message handler registrations.
	 * 
	 * @param instance the instance that has been fully configured
	 * @param context the Context the instance belongs to
	 */
	function postConstruct (instance:Object, context:Context) : void;

	/**
	 * Method to be invoked before the Context that the specified instance belongs to
	 * gets destroyed.
	 * 
	 * @param instance the instance that belongs to a Context about to get destroyed
	 * @param context the Context the instance belongs to
	 */
	function preDestroy (instance:Object, context:Context) : void;
	
}
}
