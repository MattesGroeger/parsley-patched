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
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.ScopeExtensionFactory;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

/**
 * Builder for registering scope extensions.
 * 
 * @author Jens Halm
 */
public class ScopeExtensionsBuilder implements SetupPart {
	
	
	private var setup:ContextBuilderSetup;
	private var local:Boolean;
	private var scope:String;
	
	private var _factory:ScopeExtensionFactory;
	private var id:String;
	
	
	/**
	 * @private
	 */
	function ScopeExtensionsBuilder (setup:ContextBuilderSetup, local:Boolean, scope:String) {
		this.setup = setup;
		this.local = local;
		this.scope = scope;
	}

	
	/**
	 * Adds a factory for a scope extension. The factory will be used to create a new instance
	 * of the extension for each scope that gets created.
	 * 
	 * @param factory the factory responsible for creating the extensions
	 * @param id the optional id the extension should be registered with (if omitted the factory will be registered by type)
	 * @return the original setup instance for method chaining
	 */	
	public function factory (factory:ScopeExtensionFactory, id:String = null) : ContextBuilderSetup {
		this._factory = factory;
		this.id = id;
		return setup;
	}
	
	/**
	 * @private
	 */
	public function apply (builder:CompositeContextBuilder) : void {
		var registry:FactoryRegistry = (local) ? builder.factories : GlobalFactoryRegistry.instance;
		if (_factory != null) {
			registry.scopeExtensions.addExtension(_factory, scope, id);
		}
	}
	
	
}
}
