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

package org.spicefactory.parsley.core.state {
import flash.display.DisplayObject;

/**
 * Global status information about the view hierarchy.
 * Offers utility function to either find the nearest Context in the view hierarchy above a view instance
 * or allows to configure or wait for a Context to be created in the view hierarchy below a particular view instance.
 * 
 * @author Jens Halm
 */
public interface GlobalViewState {
	
	
	/**
	 * Finds the nearest Context in the view hierarchy above the specified DisplayObject.
	 * This is an asynchronous operation, hence a callback must be specified with one parameter
	 * of type Context. It may be invoked with a null value in case no Context is found in the view
	 * hierarchy. The third parameter allows to specify an Event (any of the constants of <code>ContextEvent</code>).
	 * If specified the callback will not be invoked before that event has fired. If omitted the callback will
	 * be invoked as soon as the Context is found.
	 * 
	 * @param view the view to use as a starting point for the Context lookup
	 * @param callback the callback to invoke as soon as the Context is found and in the required state
	 * @param requiredEvent the event that needs to have been fired before the callback gets invoked
	 */
	function findContextInHierarchy (view:DisplayObject, callback:Function, requiredEvent:String = null) : void;
	
	// function configureFirstChildContext; // TODO - add in 2.4.M1 or 2.4.M2
	
	// function waitForFirstChildContext; // TODO - add in 2.4.M1 or 2.4.M2
	
}
}
