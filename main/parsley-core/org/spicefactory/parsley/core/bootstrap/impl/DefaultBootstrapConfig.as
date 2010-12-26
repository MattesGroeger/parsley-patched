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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.Delegate;
import org.spicefactory.lib.util.DelegateChain;
import org.spicefactory.parsley.binding.BindingSupport;
import org.spicefactory.parsley.core.bootstrap.ApplicationDomainProvider;
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.BootstrapProcessor;
import org.spicefactory.parsley.core.bootstrap.ConfigurationProcessor;
import org.spicefactory.parsley.core.bootstrap.ServiceRegistry;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageSettings;
import org.spicefactory.parsley.core.registry.ConfigurationProperties;
import org.spicefactory.parsley.core.scope.ScopeExtensionRegistry;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.scope.impl.DefaultScopeExtensionRegistry;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;
import org.spicefactory.parsley.core.state.GlobalState;
import org.spicefactory.parsley.core.state.manager.GlobalStateManager;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.impl.DefaultViewSettings;
import org.spicefactory.parsley.flex.modules.FlexApplicationDomainProvider;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the BootstrapConfig interface.
 * 
 * @author Jens Halm
 */
public class DefaultBootstrapConfig implements BootstrapConfig {
	
	
	private static const log:Logger = LogContext.getLogger(DefaultBootstrapManager);
	
	
	private var customScopes:DelegateChain = new DelegateChain();
	private var scopes:ScopeCollection = new ScopeCollection();
	private var processors:Array = new Array();
	private var parentConfig:BootstrapConfig;
	
	private var stateManager:GlobalStateManager = GlobalStateAccessor.stateManager;
	
	
	private var _services:DefaultServiceRegistry = new DefaultServiceRegistry();
	
	/**
	 * @inheritDoc
	 */
	public function get services () : ServiceRegistry {
		return _services;
	}
	
	
	private var _viewSettings:DefaultViewSettings = new DefaultViewSettings();
	
	/**
	 * @inheritDoc
	 */
	public function get viewSettings () : ViewSettings {
		return _viewSettings;
	}
	
	
	private var _messageSettings:DefaultMessageSettings = new DefaultMessageSettings();
	
	/**
	 * @inheritDoc
	 */
	public function get messageSettings () : MessageSettings {
		return _messageSettings;
	}


	private var _scopeExtensions:DefaultScopeExtensionRegistry = new DefaultScopeExtensionRegistry();
	
	/**
	 * @inheritDoc
	 */
	public function get scopeExtensions () : ScopeExtensionRegistry {
		return _scopeExtensions;
	}
	
	
	private var _properties:DefaultProperties = new DefaultProperties();
	
	/**
	 * @inheritDoc
	 */
	public function get properties () : ConfigurationProperties {
		return _properties;
	}

	
	private var _domain:ApplicationDomain;
	
	/**
	 * @inheritDoc
	 */
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set domain (value:ApplicationDomain) : void {
		_domain = value;
	}
	
	
	private var _domainProvider:ApplicationDomainProvider;
	
	/**
	 * @inheritDoc
	 */
	public function get domainProvider () : ApplicationDomainProvider {
		return (_domainProvider) ? _domainProvider : (parentConfig) ? parentConfig.domainProvider : null;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set domainProvider (value:ApplicationDomainProvider) : void {
		_domainProvider = value;
	}
	
	
	private var _parent:Context;
	
	/**
	 * @inheritDoc
	 */
	public function get parent () : Context {
		return _parent;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set parent (value:Context) : void {
		_parent = value;
	}
	
	
	private var _viewRoot:DisplayObject;
	
	/**
	 * @inheritDoc
	 */
	public function get viewRoot () : DisplayObject {
		return _viewRoot;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set viewRoot (value:DisplayObject) : void {
		_viewRoot = value;
	}


	private var _description:String;
	
	/**
	 * @inheritDoc
	 */
	public function get description () : String {
		return _description;
	}

	/**
	 * @inheritDoc
	 */
	public function set description (value:String) : void {
		_description = value;
	}

	
	/**
	 * @inheritDoc
	 */
	public function addScope (name:String, inherited:Boolean = true, uuid:String = null) : void {
		customScopes.addDelegate(new Delegate(addCustomScope, [name, inherited, uuid]));
	}
	
	private function addCustomScope (name:String, inherited:Boolean, uuid:String) : void {
		scopes.addScope(createScopeInfo(name, inherited, uuid));
	}
	
	/**
	 * @inheritDoc
	 */
	public function addProcessor (processor:ConfigurationProcessor) : void {
		processors.push(processor);
	}
	
	
	/**
	 * @private
	 */
	internal function createProcessor () : BootstrapProcessor {
		new FlexApplicationDomainProvider();
		BindingSupport.initialize();
		findParent();
		assembleScopeInfos();
		var info:BootstrapInfo = prepareBootstrapInfo();
		var processor:BootstrapProcessor = new DefaultBootstrapProcessor(info);
		for each (var cp:ConfigurationProcessor in processors) {
			processor.addProcessor(cp);
		}
		return processor;
	}
	
	private function findParent () : void {
		var event:ContextBuilderEvent = null;
		if (_viewRoot != null) {
			if (viewRoot.stage == null) {
				log.warn("Probably unable to look for parent Context and ApplicationDomain in the view hierarchy " +
						" - specified view root has not been added to the stage yet");
			}
			event = new ContextBuilderEvent();
			viewRoot.dispatchEvent(event);
			if (!_parent) { 
				_parent = event.parent;
			}
			if (!_domain) {
				_domain = event.domain;
			}
			event.processScopes(this);
		}
		parentConfig = (_parent) 
			? GlobalStateAccessor.stateManager.contexts.getBootstrapConfig(_parent)
			: BootstrapDefaults.config;
		_services.parent = parentConfig.services;
		_viewSettings.parent = parentConfig.viewSettings;
		_messageSettings.parent = parentConfig.messageSettings;
		_properties.parent = parentConfig.properties;
		_scopeExtensions.parent = parentConfig.scopeExtensions;
		if (!_domain && _viewRoot && domainProvider) {
			_domain = domainProvider.getDomainForView(viewRoot);
		}
		if (!_domain) {
			_domain = (_parent) ? _parent.domain : ClassInfo.currentDomain;
		}
	}
	
	private function assembleScopeInfos () : void {
		scopes.addScope(createScopeInfo(ScopeName.LOCAL, false));
		if (parent == null) {
			scopes.addScope(createScopeInfo(ScopeName.GLOBAL, true));
		}
		else {
			var parentScopes:Array = stateManager.contexts.getBootstrapInfo(parent).scopes;
			for each (var scope:ScopeInfo in parentScopes) {
				if (scope.inherited) {
					scopes.addScope(scope);
				}
			}
		}
		customScopes.invoke();
	}

	private function createScopeInfo (name:String, inherited:Boolean, uuid:String = null) : ScopeInfo {
		var extensions:Dictionary = _scopeExtensions.getAll();
		if (!uuid) {
			uuid = GlobalState.scopes.nextUuidForName(name);
		}
		return new ScopeInfo(name, inherited, uuid, services, messageSettings, extensions, stateManager.domains);
	}

	private function prepareBootstrapInfo () : BootstrapInfo {
		if (description == null) {
			description = processors.join(","); // TODO - ignores processors added later
		}
		var info:BootstrapInfo = new DefaultBootstrapInfo(this, scopes.getAll(), stateManager);
		var context:Context = info.context;
		if (log.isInfoEnabled()) {
			log.info("Creating Context " + context + 
					((_parent) ? " with parent " + _parent : " without parent"));
		}
		stateManager.contexts.addContext(context, this, info);
		return info;
	}
}
}

import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ConfigurationProperties;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;

import flash.utils.Dictionary;

class ScopeCollection {

	private var scopes:Array = new Array();
	private var nameLookup:Dictionary = new Dictionary();
	
	public function addScope (scopeDef:ScopeInfo) : void { 
		if (nameLookup[scopeDef.name] != undefined) {
			throw new ContextError("Overlapping scopes with name " + scopeDef.name);
		}
		nameLookup[scopeDef.name] = true;
		scopes.push(scopeDef);
	}
	
	public function getAll () : Array {
		return scopes;
	}
}

class DefaultProperties implements ConfigurationProperties {
	
	private var map:Dictionary = new Dictionary();
	
	public var parent:ConfigurationProperties;

	public function setValue (name:String, value:Object) : void {
		map[name] = value;
	}
	
	public function getValue (name:String) : Object {
		return (map[name]) ? map[name] : (parent) ? parent.getValue(name) : null;
	}
	
	public function removeValue (name:String) : void {
		delete map[name];
	}
	
}
