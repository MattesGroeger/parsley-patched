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

package org.spicefactory.parsley.core.context.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.events.NestedErrorEvent;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicContext;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.provider.impl.ContextObjectProviderFactory;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.ObjectDefinitionRegistryEvent;
import org.spicefactory.parsley.core.factory.ContextStrategyProvider;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

/**
 * Default implementation of the <code>Context</code> interface. 
 * 
 * <p>This implementation is not capable of handling a parent <code>Context</code>.
 * A big part of the internal work is delegated to the collaborators fetched from the <code>ContextStrategyProvider</code> 
 * passed to the constructor:
 * The <code>ObjectDefinitionRegistry</code>, <code>ObjectLifecycleManager</code>, <code>ViewManager</code> and <code>ScopeManager</code>
 * implementations.</p> 
 * 
 * @author Jens Halm
 */
public class DefaultContext extends EventDispatcher implements Context {


	private static const log:Logger = LogContext.getLogger(DefaultContext);

	
	private var strategyProvider:ContextStrategyProvider;
	private var objectProviderFactory:ContextObjectProviderFactory;
	
	private var _registry:ObjectDefinitionRegistry;
	private var _lifecycleManager:ObjectLifecycleManager;
	private var _scopeManager:ScopeManager;
	private var _viewManager:ViewManager;
	
	private var singletonCache:SimpleMap = new SimpleMap();
	private var dynamicCache:SimpleMap = new SimpleMap();
	
	private var initSequence:InitializerSequence;
	private var underConstruction:Dictionary = new Dictionary();
	
	private var _initialized:Boolean;
	private var _configured:Boolean;
	private var _destroyed:Boolean;
	
	private var description:String;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param provider instances to fetch all required strategies from
	 */
	function DefaultContext (provider:ContextStrategyProvider) {
		this.strategyProvider = provider;
		this.objectProviderFactory = new ContextObjectProviderFactory(this, strategyProvider.domain);
		provider.init(this, objectProviderFactory);
		_registry = provider.registry;
		_lifecycleManager = provider.lifecycleManager;
		_scopeManager = provider.scopeManager;
		_viewManager = provider.viewManager;
		description = provider.description;
		addEventListener(ContextEvent.DESTROYED, contextDestroyed, false, 1);
		_registry.addEventListener(ObjectDefinitionRegistryEvent.FROZEN, registryFrozen);
	}

	
	private function registryFrozen (event:Event) : void {
		_registry.removeEventListener(ObjectDefinitionRegistryEvent.FROZEN, registryFrozen);
		_configured = true;
		initialize();
	}
	
	
	/**
	 * Instantiates all non-lazy singletons. In case the Context contains objects with
	 * an AsyncInit configuration this operation may execute asynchronously. After
	 * all singletons have been instantiated the <code>initialized</code> Event will be fired.
	 */
	protected function initialize () : void {
		
		objectProviderFactory.initialize();
		
		initSequence = new InitializerSequence(this);
		dispatchEvent(new ContextEvent(ContextEvent.CONFIGURED));

		// instantiate non-lazy singletons, with or without AsyncInit config
		for each (var id:String in _registry.getDefinitionIds()) {
			var definition:RootObjectDefinition = _registry.getDefinition(id);
			if (definition is SingletonObjectDefinition && !SingletonObjectDefinition(definition).lazy) {
				initSequence.addDefinition(definition);
			}
		}
		initSequence.start();
	}

	/**
	 * @private
	 */
	internal function finishInitialization () : void {
		initSequence = null;
		_initialized = true;
		dispatchEvent(new ContextEvent(ContextEvent.INITIALIZED));
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get configured () : Boolean {
		return _configured;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get initialized () : Boolean {
		return _initialized;
	}

	/**
	 * The registry used by this Context.
	 */
	public function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}
	
	/**
	 * The manager that handles the lifecycle for all objects in this Context.
	 */
	public function get lifecycleManager () : ObjectLifecycleManager {
		return _lifecycleManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getObjectCount (type:Class = null) : uint {
		checkState();
		return _registry.getDefinitionCount(type);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getObjectIds (type:Class = null) : Array {
		checkState();
		return _registry.getDefinitionIds(type);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function containsObject (id:String) : Boolean {
		checkState();
		return _registry.containsDefinition(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getObject (id:String) : Object {
		checkState();
		return getInstance(getDefinition(id));
	}
	
	/**
	 * @inheritDoc
	 */
	public function getType (id:String) : Class {
		checkState();
		var def:ObjectDefinition = getDefinition(id);
		return def.type.getClass();
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function getAllObjectsByType (type:Class) : Array {
		checkState();
		var defs:Array = _registry.getAllDefinitionsByType(type);
		var objects:Array = new Array();
		for each (var def:RootObjectDefinition in defs) {
			objects.push(getInstance(def));
		}
		return objects;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getObjectByType (type:Class) : Object {
		checkState();
		var def:RootObjectDefinition = _registry.getDefinitionByType(type);
		return (def != null) ? getInstance(def) : null;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addDynamicDefinition (definition:DynamicObjectDefinition) : DynamicObject {
		return addDynamicObject(null, definition);
	}

	/**
	 * @inheritDoc
	 */
	public function addDynamicObject (instance:Object, definition:DynamicObjectDefinition = null) : DynamicObject {
		checkState(false);
		if (definition == null) {
			var ci:ClassInfo = ClassInfo.forInstance(instance, registry.domain);
			definition = registry.builders.forDynamicDefinition(ci.getClass()).build();
		}
		return new DefaultDynamicObject(this, definition, instance);
	}
	
	/**
	 * @private
	 */
	internal function getInstance (def:RootObjectDefinition) : Object {
		var id:String = def.id;
		
		if (def is SingletonObjectDefinition && singletonCache.containsKey(id)) {
			return singletonCache.get(id);
		}		
		
		if (underConstruction[id]) {
			throw new ContextError("Illegal type of bidirectional association. Make sure that at least" +
					" one side is a singleton, at most one side uses the constructor for injection and" +
					" none of the objects involved is a factory.");
		}
		underConstruction[id] = true;
		
		try {
			var object:ManagedObject = _lifecycleManager.createObject(def, this);
			if (def is SingletonObjectDefinition) {
				var singleton:SingletonObjectDefinition = SingletonObjectDefinition(def);
				singletonCache.put(id, object.instance);
				if (!initialized && singleton.asyncInitConfig != null && initSequence != null) {
					initSequence.addInstance(object);
				}
			}
			_lifecycleManager.configureObject(object);
		}
		finally {
			delete underConstruction[id];
		}
		return object.instance;
	}
	
	private function getDefinition (id:String) : RootObjectDefinition {
		if (!containsObject(id)) {
			throw new ContextError("Context does not contain an object with id "
					+ id);
		}
		return _registry.getDefinition(id);
	}
	
	
	/**
	 * @private
	 */
	internal function destroyWithError (message:String, cause:Object = null) : void {
		if (_initialized) {
			throw new IllegalStateError("Cannot dispatch ERROR event after INITIALIZED event");
		}
		if (_destroyed) {
			log.warn("Attempt to dispatch ERROR event after DESTROYED event");
			return;
		}
		dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, cause, message));
		destroy();
	}

	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		if (_destroyed) {
			return;
		}
		if (initSequence != null) {
			initSequence.cancel();
			initSequence = null;
		}
		try {
			dispatchEvent(new ContextEvent(ContextEvent.DESTROYED));
		}
		finally {
			_scopeManager = null;
			_destroyed = true;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get destroyed () : Boolean {
		return _destroyed;
	}
	
	private function contextDestroyed (event:Event) : void {
		_registry.removeEventListener(ObjectDefinitionRegistryEvent.FROZEN, registryFrozen);
		removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		if (_configured) {
			_lifecycleManager.destroyAll();
		}
		_configured = false;
		_initialized = false;
		_registry = null;
		_lifecycleManager = null;
	}

	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManager {
		return _scopeManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get viewManager () : ViewManager {
		return _viewManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function createDynamicContext () : DynamicContext {
		return new DefaultDynamicContext(strategyProvider.createDynamicProvider(), this);
	}
	
	private function checkState (mustBeConfigured:Boolean = true) : void {
		if (destroyed) {
			throw new IllegalStateError("Attempt to access Context after it was destroyed");
		}
		if (mustBeConfigured && !configured) {
			throw new IllegalStateError("Attempt to access Context before it was fully configured");
		}
	}
	
	
	public override function toString () : String {
		return "[Context(" + description + ")]";
	}
	
	
}

}
