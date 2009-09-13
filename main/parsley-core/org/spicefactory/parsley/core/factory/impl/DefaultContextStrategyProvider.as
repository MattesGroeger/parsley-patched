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
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class DefaultContextStrategyProvider implements ContextStrategyProvider {


	private var _registry:ObjectDefinitionRegistry;
	private var _lifecycleManager:ObjectLifecycleManager;
	private var _messageRouter:MessageRouter;
	private var _viewManager:ViewManager;
	
	private var factories:FactoryRegistry;
	private var context:Context;
	private var domain:ApplicationDomain;


	function DefaultContextStrategyProvider (factories:FactoryRegistry, domain:ApplicationDomain, 
			registry:ObjectDefinitionRegistry = null) {
		this.factories = factories;
		this.domain = domain;
		this._registry = registry;
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
	public function get messageRouter () : MessageRouter {
		checkState();
		if (_messageRouter == null) {
			_messageRouter =	factories.messageRouter.create(context, domain);
		}
		return _messageRouter;
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
	public function get createDynamicProvider () : ContextStrategyProvider {
		checkState();
		var provider:DefaultContextStrategyProvider = new DefaultContextStrategyProvider(factories, domain);
		provider._messageRouter = messageRouter;
		provider._viewManager = viewManager;
		return provider;
	}	

	
	private function checkState () : void {
		if (context == null) {
			throw new IllegalStateError("Provider has not been initialized yet");
		}
	}
}
}

