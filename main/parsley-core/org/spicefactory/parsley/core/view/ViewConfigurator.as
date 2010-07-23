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
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;

import flash.system.ApplicationDomain;

/**
 * A facility to be used by any ViewHandler that wishes to dynamically wire views to the Context.
 * 
 * @author Jens Halm
 */
public interface ViewConfigurator {
	
	
	/**
	 * The ApplicationDomain to use for reflecting on view components.
	 */
	function get domain () : ApplicationDomain;
	
	/**
	 * Indicates whether the specified target instance should be automatically removed
	 * from the Context when it gets removed from the stage.
	 * The implementation should look up the <code>[Autoremove]</code> metadata tag on the 
	 * provided view instance.
	 * 
	 * @param target the instance to determine the autoremove mode for
	 * @param defaultMode the default to return in case the target does not provide a value itself
	 * @return true if the specified target instance should be automatically removed
	 * from the Context when it gets removed from the stage
	 */
	function isAutoremove (target:Object, defaultMode:Boolean) : Boolean;
	
	/**
	 * Indicates whether the specified target instance is already wired to the Context.
	 * 
	 * @param target the instance to determine the status for
	 * @return true if the specified target instance is already wired to the Context
	 */
	function isConfigured (target:Object) : Boolean;
	
	/**
	 * Adds the specified target instance to the Context, using the specified definition.
	 * 
	 * @param target the instance to add to the Context
	 * @param definition the definition to use to configure the target instance
	 */
	function configure (target:Object, definition:DynamicObjectDefinition = null) : void;
	
	/**
	 * Returns the definition for the specified target instance and id.
	 * If a match by id cannot be found the implementation should look for a match by type.
	 * 
	 * @param configTarget the target instance to look up the definition for
	 * @param configId the configuration id of the object
	 * @return the definition for the specified target instance and id
	 */
	function getDefinition (configTarget:Object, configId:String) : DynamicObjectDefinition;
	
	
}
}
