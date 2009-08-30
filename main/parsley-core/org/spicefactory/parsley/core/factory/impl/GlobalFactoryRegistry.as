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
import org.spicefactory.parsley.core.factory.ObjectDefinitionRegistryFactory;
import org.spicefactory.parsley.core.factory.ObjectLifecycleManagerFactory;
import org.spicefactory.parsley.core.factory.ViewManagerFactory;

/**
 * @author Jens Halm
 */
public class GlobalFactoryRegistry implements FactoryRegistry {

	
	private var _contextBuilder:ContextBuilderFactory;
	private var _context:ContextFactory;
	private var _lifecycleManager:ObjectLifecycleManagerFactory;
	private var _definitionRegistry:ObjectDefinitionRegistryFactory;
	private var _viewManager:ViewManagerFactory;
	private var _messageRouter:MessageRouterFactory;
	
	
	private static var _instance:FactoryRegistry;
	
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
			_viewManager = new DefaultViewManagerFactory();
		}
		return _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get messageRouter () : MessageRouterFactory {
		if (_messageRouter == null) {
			_messageRouter = new DefaultMessageRouterFactory();
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
	
	public function set messageRouter (value:MessageRouterFactory) : void {
		_messageRouter = value;
	}
}
}

import org.spicefactory.parsley.metadata.MetadataDecoratorAssembler;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.factory.ContextBuilderFactory;
import org.spicefactory.parsley.core.factory.ContextFactory;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.ObjectDefinitionRegistryFactory;
import org.spicefactory.parsley.core.factory.ObjectLifecycleManagerFactory;
import org.spicefactory.parsley.core.factory.ViewManagerFactory;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.lifecycle.impl.DefaultObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageRouter;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionRegistry;

import flash.system.ApplicationDomain;

class DefaultContextBuilderFactory implements ContextBuilderFactory {
	
	public function create (parent:Context = null, domain:ApplicationDomain = null) : CompositeContextBuilder {
		return new DefaultCompositeContextBuilder(parent, domain);
	}
	
}

class DefaultContextFactory implements ContextFactory {
	
	public function create (factories:FactoryRegistry, registry:ObjectDefinitionRegistry, parent:Context = null) : Context {
		return (parent != null) ? new ChildContext(parent, registry, factories) : new DefaultContext(registry, factories);
	}
	
}

class DefaultLifecycleManagerFactory implements ObjectLifecycleManagerFactory {
	
	public function create (domain:ApplicationDomain) : ObjectLifecycleManager {
		return new DefaultObjectLifecycleManager(domain);
	}
	
}

class DefaultDefinitionRegistryFactory implements ObjectDefinitionRegistryFactory {

	public function create (domain:ApplicationDomain) : ObjectDefinitionRegistry {
		return new DefaultObjectDefinitionRegistry(domain, [new MetadataDecoratorAssembler(domain)]);
	}
	
}

class DefaultViewManagerFactory implements ViewManagerFactory {
	// TODO - implement after ViewManager has been implemented
}

class DefaultMessageRouterFactory implements MessageRouterFactory {
	
	public function create (context:Context) : MessageRouter {
		return new DefaultMessageRouter(context);
	}
	
}



