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

package org.spicefactory.parsley.core.bootstrap {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProviderFactory;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.state.manager.GlobalStateManager;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.ViewSettings;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Represents the environment for a single Context building process in a read-only way.
 * Implementations of this interface get passed to kernel services that implement
 * the <code>InitializingService</code> interface. They can be used to get access to
 * collaborating services or other environment settings.
 * 
 * @author Jens Halm
 */
public interface BootstrapInfo {
	
	
	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#description
	 */
	function get description () : String;
	
	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#viewRoot
	 */
	function get viewRoot () : DisplayObject;
	
	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#domain
	 */
	function get domain () : ApplicationDomain;
	
	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#parent
	 */
	function get parent () : Context;

	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#viewSettings
	 */
	function get viewSettings () : ViewSettings;
	
	/**
	 * @copy org.spicefactory.parsley.bootstrap.BootstrapConfig#messageSettings
	 */
	function get messageSettings () : MessageSettings;
	
	/**
	 * The manager for the global state of all existing Contexts
	 */
	function get globalState () : GlobalStateManager;

	
	/**
	 * The Context under construction.
	 */
	function get context () : Context;
	
	/**
	 * The registry for object definitions. In the bootstrap phase the registry can be used
	 * to register new object definitions.
	 */
	function get registry () : ObjectDefinitionRegistry;

	/**
	 * The service that handles the lifecycle of managed objects.
	 * Normally only needed by the Context implementation.
	 */
	function get lifecycleManager () : ObjectLifecycleManager;

	/**
	 * The service that manages all aspects of view wiring.
	 * Normally only needed by the Context implementation.
	 */
	function get viewManager () : ViewManager;
	
	/**
	 * The service that manages the scopes for a particular Context.
	 * Normally only needed by the Context implementation.
	 */
	function get scopeManager () : ScopeManager;
	
	/**
	 * The scopes associated with the Context under construction.
	 * An Array of instances of <code>ScopeInfo</code>.
	 */
	function get scopes () : Array;

	
	[Deprecated]
	function get objectProviderFactory () : ObjectProviderFactory;

	[Deprecated]
	function set objectProviderFactory (value:ObjectProviderFactory) : void;
	
	[Deprecated]
	function createDynamicInfo () : BootstrapInfo;
	
	
}
}
