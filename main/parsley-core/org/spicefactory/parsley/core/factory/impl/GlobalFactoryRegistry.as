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
import org.spicefactory.parsley.core.factory.ContextBuilderFactory;
import org.spicefactory.parsley.core.factory.ContextFactory;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.MessageSettings;
import org.spicefactory.parsley.core.factory.ObjectDefinitionRegistryFactory;
import org.spicefactory.parsley.core.factory.ObjectLifecycleManagerFactory;
import org.spicefactory.parsley.core.factory.ScopeExtensionRegistry;
import org.spicefactory.parsley.core.factory.ScopeManagerFactory;
import org.spicefactory.parsley.core.factory.ViewManagerFactory;
import org.spicefactory.parsley.core.factory.ViewSettings;

/**
 * Global registry for all factories responsible for creating the individual services of the Parsley IOC kernel.
 * For each internal service Parsley contains a default implementation, so this registry only needs to be used
 * if custom implementations of one or more services should replace the builtin ones.
 * 
 * <p>The global registry is a singleton accessible through <code>GlobalFactoryRegistry.instance</code>.</p>
 * 
 * @author Jens Halm
 */
public class GlobalFactoryRegistry implements FactoryRegistry {

	
	private var _contextBuilder:ContextBuilderFactory;
	private var _context:ContextFactory;
	private var _lifecycleManager:ObjectLifecycleManagerFactory;
	private var _definitionRegistry:ObjectDefinitionRegistryFactory;
	private var _scopeManager:ScopeManagerFactory;
	private var _viewManager:ViewManagerFactory;
	private var _messageRouter:MessageRouterFactory;
	private var _scopeExtensions:ScopeExtensionRegistry = new DefaultScopeExtensionRegistry();
	private var _messageSettings:DefaultMessageSettings = new DefaultMessageSettings();
	private var _viewSettings:DefaultViewSettings = new DefaultViewSettings();
	
	
	private static var _instance:FactoryRegistry;
	
	/**
	 * The singleton instance of the global factory registry.
	 */
	public static function get instance () : FactoryRegistry {
		if (_instance == null) {
			_instance = new GlobalFactoryRegistry();
		}
		return _instance;
	}

	/**
	 * @inheritDoc
	 */
	public function get contextBuilder () : ContextBuilderFactory {
		if (_contextBuilder == null) {
			_contextBuilder = new DefaultContextBuilderFactory();
		}
		return _contextBuilder;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get context () : ContextFactory {
		if (_context == null) {
			_context = new DefaultContextFactory();
		}
		return _context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lifecycleManager () : ObjectLifecycleManagerFactory {
		if (_lifecycleManager == null) {
			_lifecycleManager = new DefaultLifecycleManagerFactory();
		}
		return _lifecycleManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get definitionRegistry () : ObjectDefinitionRegistryFactory {
		if (_definitionRegistry == null) {
			_definitionRegistry = new DefaultDefinitionRegistryFactory();
		}
		return _definitionRegistry;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get viewManager () : ViewManagerFactory {
		if (_viewManager == null) {
			_viewManager = new DefaultViewManagerFactory(viewSettings);
		}
		return _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManagerFactory {
		if (_scopeManager == null) {
			_scopeManager = new DefaultScopeManagerFactory();
		}
		return _scopeManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get messageRouter () : MessageRouterFactory {
		if (_messageRouter == null) {
			_messageRouter = new DefaultMessageRouterFactory(messageSettings);
		}
		return _messageRouter;
	}
	
	public function set contextBuilder (value:ContextBuilderFactory) : void {
		_contextBuilder = value;
	}
	
	public function set context (value:ContextFactory) : void {
		_context = value;
	}
	
	public function set lifecycleManager (value:ObjectLifecycleManagerFactory) : void {
		_lifecycleManager = value;
	}
	
	public function set definitionRegistry (value:ObjectDefinitionRegistryFactory) : void {
		_definitionRegistry = value;
	}
	
	public function set viewManager (value:ViewManagerFactory) : void {
		_viewManager = value;
	}
	
	public function set scopeManager (value:ScopeManagerFactory) : void {
		_scopeManager = value;
	}
	
	public function set messageRouter (value:MessageRouterFactory) : void {
		_messageRouter = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get scopeExtensions () : ScopeExtensionRegistry {
		return _scopeExtensions;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get messageSettings () : MessageSettings {
		return _messageSettings;
	}

	/**
	 * @inheritDoc
	 */
	public function get viewSettings () : ViewSettings {
		return _viewSettings;
	}
}
}

import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.context.provider.ObjectProviderFactory;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.factory.ContextBuilderFactory;
import org.spicefactory.parsley.core.factory.ContextFactory;
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.MessageSettings;
import org.spicefactory.parsley.core.factory.ObjectDefinitionRegistryFactory;
import org.spicefactory.parsley.core.factory.ObjectLifecycleManagerFactory;
import org.spicefactory.parsley.core.factory.ScopeManagerFactory;
import org.spicefactory.parsley.core.factory.ViewManagerFactory;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.lifecycle.impl.DefaultObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageRouter;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.scope.impl.DefaultScopeManager;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.impl.DefaultViewManager;
import org.spicefactory.parsley.metadata.MetadataDecoratorAssembler;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.system.ApplicationDomain;

class DefaultContextBuilderFactory implements ContextBuilderFactory {
	
	public function create (viewRoot:DisplayObject = null, parent:Context = null, 
			domain:ApplicationDomain = null, description:String = null) : CompositeContextBuilder {
		return new DefaultCompositeContextBuilder(viewRoot, parent, domain, description);
	}
	
}

class DefaultContextFactory implements ContextFactory {
	
	public function create (provider:ContextStrategyProvider, parent:Context = null) : Context {
		return (parent != null) ? new ChildContext(provider, parent) : new DefaultContext(provider);
	}
	
}

class DefaultLifecycleManagerFactory implements ObjectLifecycleManagerFactory {
	
	public function create (domain:ApplicationDomain, scopes:Array) : ObjectLifecycleManager {
		return new DefaultObjectLifecycleManager(domain, scopes);
	}
	
}

class DefaultDefinitionRegistryFactory implements ObjectDefinitionRegistryFactory {

	public function create (domain:ApplicationDomain, context:Context, 
			providerFactory:ObjectProviderFactory) : ObjectDefinitionRegistry {
		return new DefaultObjectDefinitionRegistry(domain, 
				context, 
				providerFactory, 
				[new MetadataDecoratorAssembler()]);
	}
	
}

class DefaultViewManagerFactory implements ViewManagerFactory {
	
	private var settings:ViewSettings;
	
	private var defaultRemovedEvent:String = Event.REMOVED_FROM_STAGE;
	private var customRemovedEvent:String = "removeView";
	private var defaultAddedEvent:String = ViewConfigurationEvent.CONFIGURE_VIEW;


	function DefaultViewManagerFactory (viewSettings:ViewSettings) {
		this.settings = viewSettings;
	}

	public function create (context:Context, domain:ApplicationDomain, settings:ViewSettings) : ViewManager {
		return new DefaultViewManager(context, domain, settings);
	}
	
	public function get viewRootRemovedEvent () : String {
		return (settings.autoremoveViewRoots) ? defaultRemovedEvent : customRemovedEvent;
	}
	
	public function set viewRootRemovedEvent (viewRootRemovedEvent:String) : void {
		settings.autoremoveViewRoots = (viewRootRemovedEvent == defaultRemovedEvent);
	}

	public function get componentRemovedEvent () : String {
		return (settings.autoremoveComponents) ? defaultRemovedEvent : customRemovedEvent;
	}
	
	public function set componentRemovedEvent (componentRemovedEvent:String) : void {
		settings.autoremoveComponents = (viewRootRemovedEvent == defaultRemovedEvent);
	}
	
	public function get componentAddedEvent () : String {
		return defaultAddedEvent;
	}
	
	public function set componentAddedEvent (componentAddedEvent:String) : void {
		if (componentAddedEvent != defaultAddedEvent) {
			throw new IllegalArgumentError("Custom event types for componentAddedEvent are no longer supported");
		}
	}
	
	public function get autowireFilter () : ViewAutowireFilter {
		return settings.autowireFilter;
	}
	
	public function set autowireFilter (value:ViewAutowireFilter) : void {
		settings.autowireFilter = value;
	}
	
	
}

class DefaultScopeManagerFactory implements ScopeManagerFactory {
	
	public function create (context:Context, scopeDefs:Array, domain:ApplicationDomain) : ScopeManager {
		return new DefaultScopeManager(context, scopeDefs, domain);
	}
	
}

class DefaultMessageRouterFactory implements MessageRouterFactory {


	private var settings:MessageSettings;
	
	function DefaultMessageRouterFactory (settings:MessageSettings) {
		this.settings = settings;
	}

	public function get unhandledError () : ErrorPolicy {
		return settings.unhandledError;
	}

	public function set unhandledError (policy:ErrorPolicy) : void {
		settings.unhandledError = policy;
	}

	public function addErrorHandler (handler:MessageErrorHandler) : void {
		settings.addErrorHandler(handler);
	}
	
	public function addCommandFactory (type:Class, factory:CommandFactory) : void {
		settings.commandFactories.addCommandFactory(type, factory);
	}

	public function create (unhandledError:ErrorPolicy) : MessageRouter {
		return new DefaultMessageRouter(settings);
	}
	
	
}


