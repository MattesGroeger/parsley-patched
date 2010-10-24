/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.core.builder.impl {
import org.spicefactory.lib.util.Delegate;
import org.spicefactory.lib.util.DelegateChain;
import org.spicefactory.lib.events.CompoundErrorEvent;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.binding.BindingSupport;
import org.spicefactory.parsley.core.builder.AsyncConfigurationProcessor;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.ContextUtil;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.DefaultContextStrategyProvider;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.LocalFactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeExtensions;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.scope.impl.ScopeDefinition;

import flash.display.DisplayObject;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * Default implementation of the CompositeContextBuilder interface.
 * 
 * @author Jens Halm
 */
public class DefaultCompositeContextBuilder implements CompositeContextBuilder {

	
	private static const log:Logger = LogContext.getLogger(DefaultCompositeContextBuilder);

	
	private var _factories:LocalFactoryRegistry;
	private var _registry:ObjectDefinitionRegistry;
	
	private var description:String;
	
	private var viewRoot:DisplayObject;
	private var context:Context;
	private var parent:Context;
	private var domain:ApplicationDomain;
	
	private var customScopes:DelegateChain = new DelegateChain();
	private var scopes:ScopeCollection = new ScopeCollection();
	private var processors:Array = new Array();
	private var currentProcessor:Object;
	private var processed:Boolean;
	
	private var errors:Array = new Array();
	private var async:Boolean = false;

	
	/**
	 * Creates a new instance
	 * 
	 * @param viewRoot the initial view root to manage for the Context this instance creates
	 * @param parent the (optional) parent of the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @param description a description to be passed to the Context for logging or monitoring purposes
	 */
	function DefaultCompositeContextBuilder (viewRoot:DisplayObject = null, parent:Context = null, 
			domain:ApplicationDomain = null, description:String = null) {
		_factories = new LocalFactoryRegistry();
		this.viewRoot = viewRoot;
		var event:ContextBuilderEvent = null;
		if ((parent == null || domain == null) && viewRoot != null) {
			if (viewRoot.stage == null) {
				log.warn("Probably unable to look for parent Context and ApplicationDomain in the view hierarchy " +
						" - specified view root has not been added to the stage yet");
			}
			event = new ContextBuilderEvent();
			viewRoot.dispatchEvent(event);
		}
		this.parent = (parent != null) ? parent : (event != null) ? event.parent : null;
		this.domain = (domain != null) ? domain : (event != null && event.domain != null) ? event.domain : ClassInfo.currentDomain;
		if (event) event.processScopes(this);
		this.description = description;
	}

	
	[Deprecated(replacement="addProcessor")]
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		processors.push(builder);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addProcessor (processor:ConfigurationProcessor) : void {
		processors.push(processor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addScope (name:String, inherited:Boolean = true, uuid:String = null) : void {
		customScopes.addDelegate(new Delegate(addCustomScope, [name, inherited, uuid]));
	}
	
	private function addCustomScope (name:String, inherited:Boolean, uuid:String) : void {
		scopes.addScope(createScopeDefinition(name, inherited, uuid));
	}

	/**
	 * @inheritDoc
	 */
	public function get factories () : FactoryRegistry {
		return _factories;
	}
	
	private function assembleScopeDefinitions () : void {
		scopes.addScope(createScopeDefinition(ScopeName.LOCAL, false));
		if (parent == null) {
			scopes.addScope(createScopeDefinition(ScopeName.GLOBAL, true));
		}
		else {
			for each (var inheritedScope:ScopeDefinition in ContextRegistry.getScopes(parent)) {
				scopes.addScope(inheritedScope);
			}
		}
		customScopes.invoke();
	}

	private function createScopeDefinition (name:String, inherited:Boolean, uuid:String = null) : ScopeDefinition {
		var extensions:ScopeExtensions = factories.scopeExtensions.getExtensions(name);
		if (!uuid) {
			uuid = ContextUtil.globalScopeRegistry.nextUuidForName(name);
		}
		return new ScopeDefinition(name, inherited, uuid, factories, extensions);
	}
	
	private function createContext () : void {
		var provider:ContextStrategyProvider = createContextStrategyProvider(domain, scopes.getAll());
		context = _factories.context.create(provider, parent);
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		ContextRegistry.addContext(context, scopes.getInherited());
		ReflectionCacheManager.addDomain(context, domain);
		_registry = provider.registry;
		if (viewRoot != null) {
			context.viewManager.addViewRoot(viewRoot);
		}
	}
	
	private function createContextStrategyProvider (domain:ApplicationDomain, scopeDefs:Array) : ContextStrategyProvider {
		var descr:String = (description != null)
				? description : processors.join(",");
		return new DefaultContextStrategyProvider(factories, domain, scopeDefs, descr);
	}

	/**
	 * @inheritDoc
	 */
	public function build () : Context {
		if (processed) {
			log.warn("Context was already built. Returning existing instance");
			return context;
		}
		prepareRegistry();
		processConfiguration();
		return context;	
	}
	
	/**
	 * @inheritDoc
	 */
	public function prepareRegistry () : ObjectDefinitionRegistry {
		if (_registry != null) {
			return _registry;
		}
		_factories.activate(GlobalFactoryRegistry.instance);
		BindingSupport.initialize();
		assembleScopeDefinitions();
		createContext();
		return _registry;
	}
	
	private function processConfiguration () : void {
		if (context == null) {
			prepareRegistry();
		}
		invokeNextProcessor();
		if (currentProcessor != null) {
			async = true;
		}
		processed = true;
	}
	
	private function invokeNextProcessor () : void {
		if (processors.length == 0) {
			context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
			if (errors.length > 0) {
				handleErrors();
			}
			else {
				context.addEventListener(ErrorEvent.ERROR, contextError);
				_registry.freeze();
				context.removeEventListener(ErrorEvent.ERROR, contextError);
				if (errors.length > 0) {
					handleErrors();
				}
			}
		}
		else {
			var async:Boolean = false;
			try {
				var processor:Object = processors.shift();
				if (processor is ConfigurationProcessor) {
					async = !handleProcessor(ConfigurationProcessor(processor));
				}
				else {
					async = !handleLegacyBuilder(ObjectDefinitionBuilder(processor));
				}
			} catch (e:Error) {
				removeCurrentProcessor();
				log.error("Error processing {0}: {1}", e);
				errors.push(e);
			}
			if (!async)	invokeNextProcessor();
		}
	}
	
	private function handleProcessor (processor:ConfigurationProcessor) : Boolean {
		if (processor is AsyncConfigurationProcessor) {
			currentProcessor = processor;
			var asyncProcessor:AsyncConfigurationProcessor = AsyncConfigurationProcessor(processor);
			asyncProcessor.addEventListener(Event.COMPLETE, processorComplete);				
			asyncProcessor.addEventListener(ErrorEvent.ERROR, processorError);		
			asyncProcessor.processConfiguration(_registry);
			return false;
		}
		else {
			ConfigurationProcessor(processor).processConfiguration(_registry);
			return true;
		}
	}
	
	private function handleLegacyBuilder (builder:ObjectDefinitionBuilder) : Boolean {
		/* TODO - deprecated - remove in later versions */
		if (builder is AsyncObjectDefinitionBuilder) {
			currentProcessor = builder;
			var asyncBuilder:AsyncObjectDefinitionBuilder = AsyncObjectDefinitionBuilder(builder);
			asyncBuilder.addEventListener(Event.COMPLETE, processorComplete);				
			asyncBuilder.addEventListener(ErrorEvent.ERROR, processorError);		
			asyncBuilder.build(_registry);
			return false;
		}
		else {
			builder.build(_registry);
			return true;
		}
	}
	
	private function handleErrors () : void {
		var msg:String = "One or more errors in CompositeContextBuilder";
		if (async) {
			context.dispatchEvent(new CompoundErrorEvent(ErrorEvent.ERROR, errors, msg));
		}
		else {
			throw new ContextBuilderError(msg, errors);
		}		
	}
	
	private function processorComplete (event:Event) : void {
		removeCurrentProcessor();
		invokeNextProcessor();
	}
	
	private function processorError (event:ErrorEvent) : void {
		removeCurrentProcessor();
		log.error(event.text);
		errors.push(event);
		invokeNextProcessor();
	}
	
	private function removeCurrentProcessor () : void {
		if (currentProcessor == null) return;
		currentProcessor.removeEventListener(Event.COMPLETE, processorComplete);				
		currentProcessor.removeEventListener(ErrorEvent.ERROR, processorError);
		currentProcessor = null;			
	}
	
	private function contextError (event:ErrorEvent) : void {
		log.error("Error initializing Context: " + event.text);
		errors.push(event);
	}
	
	private function contextDestroyed (event:Event) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		if (currentProcessor != null) {
			currentProcessor.cancel();
		}
	}
	

}
}

import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.scope.impl.ScopeDefinition;

import flash.utils.Dictionary;

class ScopeCollection {

	private var scopes:Array = new Array();
	private var inherited:Array = new Array();
	private var nameLookup:Dictionary = new Dictionary();
	
	public function addScope (scopeDef:ScopeDefinition) : void { 
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


