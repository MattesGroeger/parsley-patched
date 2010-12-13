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

package org.spicefactory.parsley.core.bootstrap.impl {
import org.spicefactory.parsley.core.state.manager.GlobalStateManager;
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.InitializingService;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProviderFactory;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Default implementation of the BootstrapConfig interface.
 * 
 * @author Jens Halm
 */
public class DefaultBootstrapInfo implements BootstrapInfo {
	
	
	private var config:BootstrapConfig;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param config the configuration instance to use for the Context getting built
	 * @param the scopes to be created by the Context getting built
	 */
	function DefaultBootstrapInfo (config:BootstrapConfig, scopes:Array, globalState:GlobalStateManager) {
		this.config = config;
		this._scopes = scopes;
		this._globalState = globalState;
	}

	
	/**
	 * @inheritDoc
	 */
	public function get description () : String {
		return config.description;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get viewRoot () : DisplayObject {
		return config.viewRoot;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get domain () : ApplicationDomain {
		return config.domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get parent () : Context {
		return config.parent;
	}

	/**
	 * @inheritDoc
	 */
	public function get viewSettings () : ViewSettings {
		return config.viewSettings;
	}
	
	private var _globalState:GlobalStateManager;
	
	/**
	 * @inheritDoc
	 */
	public function get globalState () : GlobalStateManager {
		return _globalState;
	}

	/**
	 * @inheritDoc
	 */
	public function get messageSettings () : MessageSettings {
		return config.messageSettings;
	}


	private var _context:Context;
	
	/**
	 * @inheritDoc
	 */
	public function get context () : Context {
		if (_context == null) {
			_context = config.services.context.newInstance() as Context;
			initScopeDefinitions();
			initializeService(_context);
			if (config.viewRoot != null) {
				_context.viewManager.addViewRoot(config.viewRoot);
			}
		}
		return _context;
	}
	
	
	private var _registry:ObjectDefinitionRegistry;
	
	/**
	 * @inheritDoc
	 */
	public function get registry () : ObjectDefinitionRegistry {
		if (_registry == null) {
			_registry = config.services.definitionRegistry.newInstance() as ObjectDefinitionRegistry;
			initializeService(_registry);
		}
		return _registry;
	}


	private var _lifecycleManager:ObjectLifecycleManager;
	
	/**
	 * @inheritDoc
	 */
	public function get lifecycleManager () : ObjectLifecycleManager {
		if (_lifecycleManager == null) {
			_lifecycleManager = config.services.lifecycleManager.newInstance() as ObjectLifecycleManager;
			initializeService(_lifecycleManager);
		}
		return _lifecycleManager;
	}


	private var _viewManager:ViewManager;
	
	/**
	 * @inheritDoc
	 */
	public function get viewManager () : ViewManager {
		if (_viewManager == null) {
			_viewManager = config.services.viewManager.newInstance() as ViewManager;
			initializeService(_viewManager);
		}
		return _viewManager;
	}


	private var _scopeManager:ScopeManager;
	
	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManager {
		if (_scopeManager == null) {
			_scopeManager = config.services.scopeManager.newInstance() as ScopeManager;
			initializeService(_scopeManager);
			registerScopes();
		}
		return _scopeManager;
	}
	
	
	private function initializeService (service:Object) : void {
		if (service is InitializingService) {
			InitializingService(service).init(this);
		}
	}
	
	
	private var _scopes:Array;
	
	/**
	 * @inheritDoc
	 */
	public function get scopes () : Array {
		return _scopes.concat();
	}
	
	private function initScopeDefinitions () : void {
		for each (var scope:ScopeInfo in scopes) {
			if (!scope.rootContext) {
				scope.rootContext = context;
			}
		}
	}
	
	private function registerScopes () : void {
		for each (var scope:Scope in _scopeManager.getAllScopes()) {
			if (scope.rootContext == context) {
				_globalState.scopes.addScope(scope);
			}
		}
	}

	
	
	private var _objectProviderFactory:ObjectProviderFactory;
	
	[Deprecated]
	public function get objectProviderFactory () : ObjectProviderFactory {
		return _objectProviderFactory;
	}
	
	[Deprecated]
	public function set objectProviderFactory (value:ObjectProviderFactory) : void {
		_objectProviderFactory = value;
	}
	
	[Deprecated]
	public function createDynamicInfo () : BootstrapInfo {
		var info:DefaultBootstrapInfo 
				= new DynamicBootstrapInfo(config, scopes, globalState, context);
		info._scopeManager = scopeManager;
		info._viewManager = viewManager;
		return info;
	}
	

}
}

import org.spicefactory.parsley.core.state.manager.GlobalStateManager;
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.impl.DefaultBootstrapInfo;
import org.spicefactory.parsley.core.context.Context;

class DynamicBootstrapInfo extends DefaultBootstrapInfo {
	
	function DynamicBootstrapInfo (config:BootstrapConfig, scopes:Array, globalState:GlobalStateManager, parent:Context) {
		super(config, scopes, globalState);
		_parent = parent;
	}
	
	private var _parent:Context;
	
	public override function get parent () : Context {
		return _parent;
	}
	
}
