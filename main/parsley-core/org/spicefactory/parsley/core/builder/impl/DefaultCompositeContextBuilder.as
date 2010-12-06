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
import org.spicefactory.parsley.core.factory.impl.LegacyFactoryRegistry;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.bootstrap.BootstrapManager;
import org.spicefactory.parsley.core.bootstrap.BootstrapProcessor;
import org.spicefactory.parsley.core.bootstrap.ConfigurationProcessor;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Default implementation of the CompositeContextBuilder interface.
 * 
 * @author Jens Halm
 */
public class DefaultCompositeContextBuilder implements CompositeContextBuilder {

	
	//private static const log:Logger = LogContext.getLogger(DefaultCompositeContextBuilder);

	
	private var manager:BootstrapManager;
	private var processor:BootstrapProcessor;
	
	/*
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
	*/
	
	/**
	 * Creates a new instance
	 * 
	 * @param viewRoot the initial view root to manage for the Context this instance creates
	 * @param parent the (optional) parent of the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @param description a description to be passed to the Context for logging or monitoring purposes
	 */
	function DefaultCompositeContextBuilder (viewRoot:DisplayObject = null, parent:Context = null, 
			domain:ApplicationDomain = null, description:String = null, manager:BootstrapManager = null) {
		/*
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
		 */
		this.manager = (manager) 
				? manager
				: BootstrapDefaults.config.services.bootstrapManager.newInstance() as BootstrapManager;
		this.manager.config.viewRoot = viewRoot;
		this.manager.config.parent = parent;
		this.manager.config.domain = domain;
		this.manager.config.description = description;
	}

	
	[Deprecated(replacement="addProcessor")]
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		if (builder is AsyncObjectDefinitionBuilder) {
			addProcessor(new WrappedAsyncConfigurationProcessor(builder as AsyncObjectDefinitionBuilder)); 
		}
		else {
			addProcessor(new WrappedConfigurationProcessor(builder));
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addProcessor (processor:ConfigurationProcessor) : void {
		manager.config.addProcessor(processor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addScope (name:String, inherited:Boolean = true, uuid:String = null) : void {
		manager.config.addScope(name, inherited, uuid);
	}
	
	/*
	private function addCustomScope (name:String, inherited:Boolean, uuid:String) : void {
		scopes.addScope(createScopeDefinition(name, inherited, uuid));
	}
	 */


	private var _factories:FactoryRegistry;
	/**
	 * @inheritDoc
	 */
	public function get factories () : FactoryRegistry {
		if (!_factories) {
			_factories = new LegacyFactoryRegistry(manager.config);
		}
		return _factories;
	}
	
	/*
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
		if (log.isInfoEnabled()) {
			log.info("Creating Context " + context + ((parent) ? " with parent " + parent : " without parent"));
		}
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
	 */

	/**
	 * @inheritDoc
	 */
	public function build () : Context {
		/*
		if (processed) {
			log.warn("Context was already built. Returning existing instance");
			return context;
		}
		prepareRegistry();
		processConfiguration();
		return context;	
		 */
		prepareRegistry();
		return processor.process();
	}
	
	/**
	 * @inheritDoc
	 */
	public function prepareRegistry () : ObjectDefinitionRegistry {
		if (!processor) {
			processor = manager.createProcessor();
		}
		return processor.info.registry;
		/*
		if (_registry != null) {
			return _registry;
		}
		_factories.activate(GlobalFactoryRegistry.instance);
		BindingSupport.initialize();
		assembleScopeDefinitions();
		createContext();
		return _registry;
		 */
	}
	
	/*
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
	 */
}
}

import org.spicefactory.parsley.core.bootstrap.AsyncConfigurationProcessor;
import org.spicefactory.parsley.core.bootstrap.ConfigurationProcessor;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

class WrappedConfigurationProcessor implements ConfigurationProcessor {

	private var legacyBuilder:ObjectDefinitionBuilder;
	
	function WrappedConfigurationProcessor (legacyBuilder:ObjectDefinitionBuilder) {
		this.legacyBuilder = legacyBuilder;
	}

	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		legacyBuilder.build(registry);
	}
	
	public function toString () : String {
		return (legacyBuilder as Object).toString();
	}
}

class WrappedAsyncConfigurationProcessor extends EventDispatcher 
		implements org.spicefactory.parsley.core.bootstrap.AsyncConfigurationProcessor {

	private var legacyBuilder:AsyncObjectDefinitionBuilder;
	
	function WrappedAsyncConfigurationProcessor (legacyBuilder:AsyncObjectDefinitionBuilder) {
		this.legacyBuilder = legacyBuilder;
		legacyBuilder.addEventListener(Event.COMPLETE, dispatchEvent);
		legacyBuilder.addEventListener(ErrorEvent.ERROR, dispatchEvent);
	}
	
	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		legacyBuilder.build(registry);
	}
	
	public function cancel () : void {
		legacyBuilder.cancel();
	}
	
	public function toString () : String {
		return (legacyBuilder as Object).toString();
	}
}


