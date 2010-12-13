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

package org.spicefactory.parsley.core.state.manager {
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.context.Context;

/**
 * Keeps track of the currently active Context instances.
 * Provides access to the <code>BootstrapInfo</code> and <code>BootstrapConfig</code> instances
 * used to create the Context. These objects are not exposed through the <code>Context</code> API,
 * but might be needed by a child Context for configuration purposes.
 * 
 * <p>This manager is usually only exposed to the IOC kernel services and can be accessed through a <code>BootstrapInfo</code>
 * instance.</p>
 * 
 * @author Jens Halm
 */
public interface GlobalContextManager {
	
	
	/**
	 * Adds the specified Context to the manager and stores the associated bootstrap instances to be used
	 * for child Context construction.
	 * 
	 * @param context the Context instance
	 * @param config the configuration for the Context
	 * @param info the environment info for the Context
	 */
	function addContext (context:Context, config:BootstrapConfig, info:BootstrapInfo) : void
	
	/**
	 * Returns the bootstrap environment information for the specified Context instance.
	 * 
	 * @param context the Context to return the bootstrap environment information for
	 * @return the bootstrap environment information for the specified Context instance
	 */
	function getBootstrapInfo (context:Context) : BootstrapInfo;

	/**
	 * Returns the bootstrap configuration for the specified Context instance.
	 * 
	 * @param context the Context to return the bootstrap configuration for
	 * @return the bootstrap configuration for the specified Context instance
	 */
	function getBootstrapConfig (context:Context) : BootstrapConfig;

	
}
}
