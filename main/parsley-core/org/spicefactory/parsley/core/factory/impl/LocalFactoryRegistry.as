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
import org.spicefactory.parsley.core.factory.ScopeManagerFactory;
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
public class LocalFactoryRegistry implements FactoryRegistry {

	
	private var _contextBuilder:ContextBuilderFactory;
	private var _context:ContextFactory;
	private var _lifecycleManager:ObjectLifecycleManagerFactory;
	private var _definitionRegistry:ObjectDefinitionRegistryFactory;
	private var _viewManager:ViewManagerFactory;
	private var _scopeManager:ScopeManagerFactory;
	private var _messageRouter:MessageRouterFactory;
	
	private var parent:FactoryRegistry;
	

	function LocalFactoryRegistry (parent:FactoryRegistry) {
		this.parent = parent;
	}

	
	/**
	 * @inheritDoc
	 */
	public function get contextBuilder () : ContextBuilderFactory {
		return (_contextBuilder == null) ? parent.contextBuilder : _contextBuilder;
	}

	/**
	 * @inheritDoc
	 */
	public function get context () : ContextFactory {
		return (_context == null) ? parent.context : _context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lifecycleManager () : ObjectLifecycleManagerFactory {
		return (_lifecycleManager == null) ? parent.lifecycleManager : _lifecycleManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get definitionRegistry () : ObjectDefinitionRegistryFactory {
		return (_definitionRegistry == null) ? parent.definitionRegistry : _definitionRegistry;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManagerFactory {
		return (_scopeManager == null) ? parent.scopeManager : _scopeManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get viewManager () : ViewManagerFactory {
		return (_viewManager == null) ? parent.viewManager : _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get messageRouter () : MessageRouterFactory {
		return (_messageRouter == null) ? parent.messageRouter : _messageRouter;
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
	
	public function set scopeManager (value:ScopeManagerFactory) : void {
		_scopeManager = value;
	}
	
	public function set viewManager (value:ViewManagerFactory) : void {
		_viewManager = value;
	}
	
	public function set messageRouter (value:MessageRouterFactory) : void {
		_messageRouter = value;
	}
	

}
}

