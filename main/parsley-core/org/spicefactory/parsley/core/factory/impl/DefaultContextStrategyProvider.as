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
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.impl.MessageRouterProxy;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scopes.Scope;
import org.spicefactory.parsley.core.scopes.ScopeManager;
import org.spicefactory.parsley.core.scopes.ScopeName;
import org.spicefactory.parsley.core.scopes.impl.ScopeDefinition;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultContextStrategyProvider implements ContextStrategyProvider {


	private var _registry:ObjectDefinitionRegistry;
	private var _lifecycleManager:ObjectLifecycleManager;
	private var _scopeManager:ScopeManager;
	private var _viewManager:ViewManager;
	
	private var factories:FactoryRegistry;
	private var context:Context;
	private var parent:Context;
	private var domain:ApplicationDomain;
	private var newScopes:Array;
	
	private static const inheritedScopeMap:Dictionary = new Dictionary();


	function DefaultContextStrategyProvider (factories:FactoryRegistry, parent:Context, domain:ApplicationDomain, 
			newScopes:Array) {
		this.factories = factories;
		this.parent = parent;
		this.domain = domain;
		this.newScopes = newScopes;
	}

	
	/**
	 * @inheritDoc
	 */
	public function init (context:Context) : void {
		this.context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get registry () : ObjectDefinitionRegistry {
		checkState();
		if (_registry == null) {
			_registry =	factories.definitionRegistry.create(domain);
		}
		return _registry;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lifecycleManager () : ObjectLifecycleManager {
		checkState();
		if (_lifecycleManager == null) {
			_lifecycleManager =	factories.lifecycleManager.create(domain);
		}
		return _lifecycleManager;
	}

	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManager {
		checkState();
		if (_scopeManager == null) {
			_scopeManager =	factories.scopeManager.createManager(createScopes(), domain);
		}
		return _scopeManager;
	}

	/**
	 * @inheritDoc
	 */	
	public function get viewManager () : ViewManager {
		checkState();
		if (_viewManager == null) {
			_viewManager =	factories.viewManager.create(context, domain);
		}
		return _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function createDynamicProvider () : ContextStrategyProvider {
		checkState();
		var provider:DefaultContextStrategyProvider = new DefaultContextStrategyProvider(factories, context, domain, []);
		provider._scopeManager = scopeManager;
		provider._viewManager = viewManager;
		return provider;
	}	

	
	private function checkState () : void {
		if (context == null) {
			throw new IllegalStateError("Provider has not been initialized yet");
		}
	}
	
	
	protected function createScopes () : Dictionary {
		var scopes:Dictionary = new Dictionary();
		newScopes.push(new ScopeDefinition(ScopeName.LOCAL, false));
		if (parent == null) {
			newScopes.push(new ScopeDefinition(ScopeName.GLOBAL, true));
		}
		else {
			for each (var scope:Scope in parent.scopeManager.getAllScopes()) {
				if (scope.inherited) {
					scopes[scope.name] = scope;
				}
			}
		}
		for each (var scopeDef:ScopeDefinition in newScopes) {
			if (scopes[scopeDef.name] != undefined) {
				throw new ContextError("Overlapping scopes with name " + scopeDef.name);
			}
			var messageRouter:MessageRouter 
					= factories.messageRouter.create(context, domain);
			var messageRouterProxy:MessageRouter 
					= new MessageRouterProxy(messageRouter, context, domain);
			var lifecycleEventRouter:MessageRouter 
					= factories.messageRouter.create(context, domain);
			var newScope:Scope 
					= factories.scopeManager.createScope(scopeDef, messageRouterProxy, lifecycleEventRouter);
			scopes[newScope.name] = newScope;
		}
		return scopes;
	}
	
	
}
}

