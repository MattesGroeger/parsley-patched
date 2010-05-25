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
import org.spicefactory.parsley.core.factory.ContextFactory;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.ObjectDefinitionRegistryFactory;
import org.spicefactory.parsley.core.factory.ObjectLifecycleManagerFactory;
import org.spicefactory.parsley.core.factory.ScopeManagerFactory;
import org.spicefactory.parsley.core.factory.ViewManagerFactory;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

/**
 * Builder for custom factories for IOC kernel services.
 * 
 * @author Jens Halm
 */
public class FactoryRegistryBuilder implements SetupPart {
	
	
	private var setup:ContextBuilderSetup;
	private var local:Boolean;
	
	private var _context:ContextFactory;
	private var _registry:ObjectDefinitionRegistryFactory;
	private var _lifecycleManager:ObjectLifecycleManagerFactory;
	private var _messageRouter:MessageRouterFactory;
	private var _scopeManager:ScopeManagerFactory;
	private var _viewManager:ViewManagerFactory;
	
	
	/**
	 * @private
	 */
	function FactoryRegistryBuilder (setup:ContextBuilderSetup, local:Boolean) {
		this.setup = setup;
		this.local = local;
	}

	/**
	 * Sets the factory responsible for creating Context instances.
	 * 
	 * @param factory the factory to use for creating Context instances
	 * @return the original setup instance for method chaining
	 */	
	public function context (factory:ContextFactory) : ContextBuilderSetup {
		_context = factory;	
		return setup;
	}
	
	/**
	 * Sets the factory responsible for creating ObjectDefinitionRegistry instances.
	 * 
	 * @param factory the factory to use for creating ObjectDefinitionRegistry instances
	 * @return the original setup instance for method chaining
	 */	
	public function registry (factory:ObjectDefinitionRegistryFactory) : ContextBuilderSetup {
		_registry = factory;	
		return setup;
	}
	
	/**
	 * Sets the factory responsible for creating ObjectLifecycleManager instances.
	 * 
	 * @param factory the factory to use for creating ObjectLifecycleManager instances
	 * @return the original setup instance for method chaining
	 */	
	public function lifecycleManager (factory:ObjectLifecycleManagerFactory) : ContextBuilderSetup {
		_lifecycleManager = factory;	
		return setup;
	}
	
	/**
	 * Sets the factory responsible for creating MessageRouter instances.
	 * 
	 * @param factory the factory to use for creating MessageRouter instances
	 * @return the original setup instance for method chaining
	 */	
	public function messageRouter (factory:MessageRouterFactory) : ContextBuilderSetup {
		_messageRouter = factory;	
		return setup;
	}
	
	/**
	 * Sets the factory responsible for creating ScopeManager instances.
	 * 
	 * @param factory the factory to use for creating ScopeManager instances
	 * @return the original setup instance for method chaining
	 */	
	public function scopeManager (factory:ScopeManagerFactory) : ContextBuilderSetup {
		_scopeManager = factory;	
		return setup;
	}
	
	/**
	 * Sets the factory responsible for creating ViewManager instances.
	 * 
	 * @param factory the factory to use for creating ViewManager instances
	 * @return the original setup instance for method chaining
	 */	
	public function viewManager (factory:ViewManagerFactory) : ContextBuilderSetup {
		_viewManager = factory;	
		return setup;
	}
	
	
	/**
	 * @private
	 */
	public function apply (builder:CompositeContextBuilder) : void {
		// TODO - replace by internal method specified in internal base class
		var registry:FactoryRegistry = (local) ? builder.factories : GlobalFactoryRegistry.instance;
		if (_context != null) {
			registry.context = _context;
		}
		if (_registry != null) {
			registry.definitionRegistry = _registry;
		}
		if (_lifecycleManager != null) {
			registry.lifecycleManager = _lifecycleManager;
		}
		if (_messageRouter != null) {
			registry.messageRouter = _messageRouter;
		}
		if (_scopeManager != null) {
			registry.scopeManager = _scopeManager;
		}
		if (_viewManager != null) {
			registry.viewManager = _viewManager;
		}
	}
	
	
}
}
