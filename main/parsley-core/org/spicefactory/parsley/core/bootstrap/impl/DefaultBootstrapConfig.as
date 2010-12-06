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
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.BootstrapProcessor;
import org.spicefactory.parsley.core.bootstrap.ConfigurationProcessor;
import org.spicefactory.parsley.core.bootstrap.ServiceRegistry;
import org.spicefactory.parsley.core.builder.impl.ContextRegistry;
import org.spicefactory.parsley.core.builder.impl.ReflectionCacheManager;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.ContextUtil;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageSettings;
import org.spicefactory.parsley.core.scope.ScopeExtensionRegistry;
import org.spicefactory.parsley.core.scope.ScopeExtensions;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.scope.impl.DefaultScopeExtensionRegistry;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.impl.DefaultViewSettings;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

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
			if (_parent == null) { 
				_parent = event.parent;
			}
			if (_domain == null) {
				_domain = event.domain;
			}
			event.processScopes(this);
		}
		if (_domain == null) {
			_domain = ClassInfo.currentDomain; // TODO - new ApplicationDomainProvider strategy
		}
		parentConfig = (_parent) 
			? ContextRegistry.getBootstrapConfig(_parent)
			: BootstrapDefaults.config;
		_services.parent = parentConfig.services;
		_viewSettings.parent = parentConfig.viewSettings;
		_messageSettings.parent = parentConfig.messageSettings;
		_scopeExtensions.parent = parentConfig.scopeExtensions;
	}
	
	private function assembleScopeInfos () : void {
		scopes.addScope(createScopeInfo(ScopeName.LOCAL, false));
		if (parent == null) {
			scopes.addScope(createScopeInfo(ScopeName.GLOBAL, true));
		}
		else {
			for each (var inheritedScope:ScopeInfo in ContextRegistry.getScopes(parent)) {
				scopes.addScope(inheritedScope);
			}
		}
		customScopes.invoke();
	}

	private function createScopeInfo (name:String, inherited:Boolean, uuid:String = null) : ScopeInfo {
		var extensions:ScopeExtensions = _scopeExtensions.getExtensions(name);
		if (!uuid) {
			uuid = ContextUtil.globalScopeRegistry.nextUuidForName(name);
		}
		return new ScopeInfo(name, inherited, uuid, services, messageSettings, extensions);
	}
	
	private function prepareBootstrapInfo () : BootstrapInfo {
		if (description == null) {
			description = processors.join(","); // TODO - ignores processors added later
		}
		var info:BootstrapInfo = new DefaultBootstrapInfo(this, scopes.getAll());
		var context:Context = info.context;
		if (log.isInfoEnabled()) {
			log.info("Creating Context " + context + 
					((_parent) ? " with parent " + _parent : " without parent"));
		}
		ContextRegistry.addContext(context, this, scopes.getInherited()); // TODO - global state
		ReflectionCacheManager.addDomain(context, domain); // TODO - global state
		return info;
	}
}
}

import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;

import flash.utils.Dictionary;

class ScopeCollection {

	private var scopes:Array = new Array();
	private var inherited:Array = new Array();
	private var nameLookup:Dictionary = new Dictionary();
	
	public function addScope (scopeDef:ScopeInfo) : void { 
		if (nameLookup[scopeDef.name] != undefined) {
			throw new ContextError("Overlapping scopes with name " + scopeDef.name);
		}
		nameLookup[scopeDef.name] = true;
		scopes.push(scopeDef);
		if (scopeDef.inherited) {
			inherited.push(scopeDef);
		}
	}
	
	public function getAll () : Array {
		return scopes;
	}
	
	public function getInherited () : Array {
		return inherited;
	}
	
}
