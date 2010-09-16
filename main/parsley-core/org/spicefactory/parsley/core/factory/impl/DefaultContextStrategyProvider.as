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

package org.spicefactory.parsley.core.factory.impl {
import org.spicefactory.parsley.core.scope.impl.DefaultScopeRegistry;
import org.spicefactory.parsley.core.scope.ScopeRegistry;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.impl.ScopeDefinition;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProviderFactory;
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.system.ApplicationDomain;

/**
 * Default implementation of the ContextStrategyProvider interface.
 * 
 * @author Jens Halm
 */
public class DefaultContextStrategyProvider implements ContextStrategyProvider {


	private var _description:String;
	private var _domain:ApplicationDomain;
	private var _registry:ObjectDefinitionRegistry;
	private var _lifecycleManager:ObjectLifecycleManager;
	private var _scopeManager:ScopeManager;
	private var _viewManager:ViewManager;
	
	private var factories:FactoryRegistry;
	private var scopeDefs:Array;
	private var context:Context;
	private var providerFactory:ObjectProviderFactory;
	
	private static const _scopeRegistry:DefaultScopeRegistry = new DefaultScopeRegistry();
	

	/**
	 * Creates a new instance.
	 * 
	 * @param factories the factories to pull collaborating services from
	 * @param domain the ApplicationDomain to use for reflection
	 * @param scopeDefs the scopes associated with the Context
	 * @param description a description to be passed to the Context for logging and monitoring purposes
	 */
	function DefaultContextStrategyProvider (factories:FactoryRegistry, domain:ApplicationDomain, 
			scopeDefs:Array, description:String) {
		this.factories = factories;
		this._domain = domain;
		this._description = description;
		this.scopeDefs = scopeDefs;
	}

	
	/**
	 * @inheritDoc
	 */
	public function init (context:Context, providerFactory:ObjectProviderFactory) : void {
		this.context = context;
		this.providerFactory = providerFactory;
		initScopeDefinitions();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get description () : String {
		return _description;
	}

	/**
	 * @inheritDoc
	 */
	public function get registry () : ObjectDefinitionRegistry {
		checkState();
		if (_registry == null) {
			_registry =	factories.definitionRegistry.create(domain, context, providerFactory);
		}
		return _registry;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lifecycleManager () : ObjectLifecycleManager {
		checkState();
		if (_lifecycleManager == null) {
			_lifecycleManager =	factories.lifecycleManager.create(domain, scopeDefs);
		}
		return _lifecycleManager;
	}

	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManager {
		checkState();
		if (_scopeManager == null) {
			_scopeManager =	factories.scopeManager.create(context, scopeDefs, domain);
			registerScopes();
		}
		return _scopeManager;
	}

	/**
	 * @inheritDoc
	 */	
	public function get viewManager () : ViewManager {
		checkState();
		if (_viewManager == null) {
			_viewManager =	factories.viewManager.create(context, domain, factories.viewSettings);
		}
		return _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function createDynamicProvider () : ContextStrategyProvider {
		checkState();
		var provider:DefaultContextStrategyProvider 
				= new DefaultContextStrategyProvider(factories, domain, scopeDefs, description);
		provider._scopeManager = scopeManager;
		provider._viewManager = viewManager;
		return provider;
	}	

	
	private function checkState () : void {
		if (context == null) {
			throw new IllegalStateError("Provider has not been initialized yet");
		}
	}
	
	private function initScopeDefinitions () : void {
		for each (var scopeDef:ScopeDefinition in scopeDefs) {
			if (!scopeDef.rootContext) {
				scopeDef.rootContext = context;
			}
		}
	}
	
	private function registerScopes () : void {
		for each (var scope:Scope in _scopeManager.getAllScopes()) {
			if (scope.rootContext == context) {
				_scopeRegistry.addScope(scope);
			}
		}
	}
	
	/**
	 * @private
	 */
	public static function get scopeRegistry () : ScopeRegistry {
		return _scopeRegistry;
	}
	
	
}
}

