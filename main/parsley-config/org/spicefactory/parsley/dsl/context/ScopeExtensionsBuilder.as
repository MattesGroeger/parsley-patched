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

package org.spicefactory.parsley.dsl.context {
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;

/**
 * Builder for registering scope extensions.
 * 
 * @author Jens Halm
 */
public class ScopeExtensionsBuilder implements SetupPart {
	
	
	private var setup:ContextBuilderSetup;
	private var scope:String;
	
	private var service:Class;
	private var params:Array;
	private var id:String;
	
	
	/**
	 * @private
	 */
	function ScopeExtensionsBuilder (setup:ContextBuilderSetup, scope:String) {
		this.setup = setup;
		this.scope = scope;
	}

	
	/**
	 * Specifies the implementation of a scope extension. A new instance
	 * of the extension will be created for each scope that gets created.
	 * 
	 * @param type the type of the extension
	 * @param params the parameters to 
	 * @param id the optional id the extension should be registered with (if omitted the factory will be registered by type)
	 * @return the original setup instance for method chaining
	 */	
	public function addExtension (type:Class, params:Array = null, id:String = null) : ContextBuilderSetup {
		this.service = type;
		this.params = params;
		this.id = id;
		return setup;
	}
	
	/**
	 * @private
	 */
	public function apply (config:BootstrapConfig) : void {
		if (service != null) {
			config.scopeExtensions.addExtension(service, params, scope, id);
		}
	}
	
	
}
}
