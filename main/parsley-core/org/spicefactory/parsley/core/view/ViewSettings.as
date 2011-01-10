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

package org.spicefactory.parsley.core.view {

/**
 * Factory responsible for creating ViewManager instances.
 * 
 * @author Jens Halm
 */
public interface ViewSettings {

	/**
	 * Indicates whether view roots should be automatically removed from the ViewManager 
	 * when they are removed from the stage. The default is <code>true</code>.
	 * When set to false view roots must dispatch a custom <code>"removeView"</code> event
	 * to signal that they wish to be removed from the ViewManager. Finally they can 
	 * be removed explicitly with <code>ViewManager.removeViewRoot</code> independent
	 * of the value for this property. 
	 */
	function get autoremoveViewRoots () : Boolean;
	
	function set autoremoveViewRoots (value:Boolean) : void;

	/**
	 * Indicates whether components should be automatically removed from the ViewManager 
	 * when they are removed from the stage. The default is <code>true</code>.
	 * When set to false components must dispatch a custom <code>"removeView"</code> event
	 * to signal that they wish to be removed from the ViewManager.
	 */
	function get autoremoveComponents () : Boolean;
	
	function set autoremoveComponents (value:Boolean) : void;

	/**
	 * Indicates wether components should be automatically wired. The default is <code>false</code>.
	 * When set to false, components can only be wired explicitly through the use of either the <code>&lt;Configure&gt;</code>
	 * or the <code>&lt;FastInject&gt;</code> tags. When set to true, they will be automatically filtered using the
	 * the filter specified with the <code>autowireFilter</code> property.
	 */
	function get autowireComponents () : Boolean;
	
	function set autowireComponents (value:Boolean) : void;
	
	/**
	 * The filter responsible for selecting views that should be autowired to the Context.
	 * Only has an effect if the <code>autowireComponents</code> flag is set to true.
	 * The default filter installed with Parsley is one that only wires views that
	 * have a matching <code>&lt;View&gt;</code> tag in the MXML or XML configuration.
	 */
	function get autowireFilter () : ViewAutowireFilter;
	
	function set autowireFilter (value:ViewAutowireFilter) : void;
	
	/**
	 * Adds a view root handler that will be added to all ViewManagers created with these settings.
	 * The provided class must implement the <code>ViewRootHandler</code> interface and provide
	 * a no-arg constructor.
	 * 
	 * @param handler the type of view handler to add
	 * @param params the parameters to pass to the constructor of the view handler
	 */
	function addViewRootHandler (handler:Class, ...params) : void;
	
	/**
	 * All view root handlers that were registered for these settings.
	 * This Array is read-only, modifications do not have any effect on
	 * the registered view handlers. Use <code>addViewRootHandler</code> to
	 * register a new handler.
	 */
	function get viewRootHandlers () : Array;
	
	
}
}
