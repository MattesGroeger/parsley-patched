/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.core.factory {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.system.ApplicationDomain;

/**
 * Factory responsible for creating ViewManager instances.
 * 
 * @author Jens Halm
 */
public interface ViewManagerFactory {
	
	
	[Deprecated(replacement="ViewSettings.autowireFilter")]
	function get autowireFilter () : ViewAutowireFilter;
	
	[Deprecated]
	function set autowireFilter (value:ViewAutowireFilter) : void;
	
	[Deprecated(replacement="ViewSettings.autoremoveViewRoots")]
	function get viewRootRemovedEvent () : String;
	
	[Deprecated]
	function set viewRootRemovedEvent (value:String) : void;

	[Deprecated(replacement="ViewSettings.autoremoveComponents")]
	function get componentRemovedEvent () : String;
	
	[Deprecated]
	function set componentRemovedEvent (value:String) : void;

	[Deprecated]
	function get componentAddedEvent () : String;
	
	[Deprecated]
	function set componentAddedEvent (value:String) : void;
	
	/**
	 * Creates a new ViewManager instance.
	 * 
	 * @param context the Context the new ViewManager will belong to
	 * @param domain the domain to use for reflection
	 * @param settings the settings to pass to the ViewManager
	 * @return a new ViewManager instance
	 */
	function create (context:Context, domain:ApplicationDomain, settings:ViewSettings) : ViewManager;

	
}
}
