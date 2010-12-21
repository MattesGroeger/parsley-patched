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

package org.spicefactory.parsley.core.scope.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.bootstrap.ServiceRegistry;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.scope.InitializingExtension;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeExtensions;
import org.spicefactory.parsley.core.state.manager.GlobalDomainManager;

import flash.utils.Dictionary;

/**
 * Holds the definition and collaborators like MessageRouters for a single scope. Instances of this class
 * will be shared by all ScopeManagers of all Context instances that
 * a scope is associated with.
 * 
 * @author Jens Halm
 */
public class ScopeInfo {
	
	
	private var services:ServiceRegistry;
	private var settings:MessageSettings;
	private var domainManager:GlobalDomainManager;
	
	private var _name:String;
	private var _uuid:String;
	private var _inherited:Boolean;
	
	private var _rootContext:Context;
	private var _lifecycleEventRouter:MessageRouter;
	private var _messageRouter:MessageRouter;
	private var _extensions:DefaultScopeExtensions;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param name the name of the scope
	 * @param inherited whether child Contexts inherit this scope 
	 * @param uuid the unique id of the scope
	 * @param factories the factories to obtain the internal MessageRouters for this scope from
	 * @param extensions the extensions registered for this scope mapped by type (Class)
	 * @param domainManager the manager that keeps track of all ApplicationDomains currently used by one or more Contexts
	 */
	function ScopeInfo (name:String, inherited:Boolean, uuid:String, 
			services:ServiceRegistry, settings:MessageSettings, extensions:Dictionary, domainManager:GlobalDomainManager) {
		_name = name;
		_uuid = uuid;
		_inherited = inherited;
		this.services = services;
		this.settings = settings;
		this.domainManager = domainManager;
		this._extensions = new DefaultScopeExtensions(extensions, initScopeExtension);
	}

	
	private function initScopeExtension (ext:Object) : void {
		if (ext is InitializingExtension) {
			var scope:Scope = rootContext.scopeManager.getScope(name);
			InitializingExtension(ext).init(scope);
		}
	}
	
	/**
	 * The name of the scope.
	 */	
	public function get name () : String {
		return _name;
	}
	
	/**
	 * The unique id of the scope.
	 */	
	public function get uuid () : String {
		return _uuid;
	}
	
	/**
	 * Indicates whether this scope will be inherited by child Contexts.
	 */
	public function get inherited () : Boolean {
		return _inherited;
	}
	
	/**
	 * The root Context of this scope.
	 */
	public function get rootContext () : Context {
		return _rootContext;
	}
	
	public function set rootContext (value:Context) : void {
		if (_rootContext) {
			throw new IllegalStateError("Root Context has already been specified for this Scope");
		}
		_rootContext = value; 
	}

		/**
	 * The router responsible for dispatching scope-wide lifecycle events.
	 */
	public function get lifecycleEventRouter () : MessageRouter {
		if (_lifecycleEventRouter == null) {
			_lifecycleEventRouter = services.messageRouter.newInstance() as MessageRouter;
			_lifecycleEventRouter.init(settings, domainManager, true);
		}
		return _lifecycleEventRouter;
	}
	
	/**
	 * The router responsible for dispatching application messages for this scope.
	 */
	public function get messageRouter () : MessageRouter {
		if (_messageRouter == null) {
			_messageRouter = services.messageRouter.newInstance() as MessageRouter;
			_messageRouter.init(settings, domainManager, false);
		}
		return _messageRouter;
	}
	
	/**
	 * The extensions registered for this scope.
	 */
	public function get extensions () : ScopeExtensions {
		return _extensions;
	}
	
	
}
}
