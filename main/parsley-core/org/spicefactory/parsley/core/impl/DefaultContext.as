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

package org.spicefactory.parsley.core.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.events.NestedErrorEvent;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.messaging.MessageRouter;
import org.spicefactory.parsley.messaging.impl.DefaultMessageRouter;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import flash.utils.getQualifiedClassName;/**
 * @author Jens Halm
 */
public class DefaultContext extends EventDispatcher implements Context {


	private static const log:Logger = LogContext.getLogger(DefaultContext);

	
	private var _registry:ObjectDefinitionRegistry;
	private var _factory:ObjectFactory;
	private var _messageRouter:MessageRouter;
	
	private var singletonCache:SimpleMap = new SimpleMap();
	
	private var asyncInitSequence:AsyncInitializerSequence;
	private var initSequence:Array;
	private var underConstruction:Dictionary = new Dictionary();
	
	private var _initialized:Boolean;
	private var _configured:Boolean;
	private var _destroyed:Boolean;
	
	
	function DefaultContext (registry:ObjectDefinitionRegistry = null, 
			messageRouter:MessageRouter = null,
			factory:ObjectFactory = null) {
		_registry = (registry != null) ? registry : new DefaultObjectDefinitionRegistry();
		_messageRouter = (messageRouter != null) ? messageRouter : new DefaultMessageRouter(this);
		_factory = (factory != null) ? factory : new DefaultObjectFactory();
		addEventListener(ContextEvent.DESTROYED, contextDestroyed, false, 1);
	}

	
	public function initialize () : void {
		
		// freeze configuration
		_registry.freeze();
		_configured = true;
		asyncInitSequence = new AsyncInitializerSequence(this);
		dispatchEvent(new ContextEvent(ContextEvent.CONFIGURED));
		
		// instantiate non-lazy singletons, those with asyncInitConfigs first
		initSequence = new Array();
		for each (var id:String in _registry.getDefinitionIds()) {
			var definition:RootObjectDefinition = _registry.getDefinition(id);
			if (definition.singleton && !definition.lazy) {
				if (definition.asyncInitConfig != null) {
					asyncInitSequence.addDefinition(definition);
				}
				else {
					initSequence.push(definition);
				}
			}
		}
		asyncInitSequence.start();
	}

	/**
	 * @private
	 */
	internal function finishInitialization () : void {
		asyncInitSequence = null;
		for each (var definition:RootObjectDefinition in initSequence) {
			try {
				getInstance(definition);
			}
			catch (e:Error) {
				destroyWithError("Error instantiating " + definition, e);
				return;
			}
		}
		initSequence = null;
		_initialized = true;
		dispatchEvent(new ContextEvent(ContextEvent.INITIALIZED));
	}
	
	
	public function get configured () : Boolean {
		return _configured;
	}
	
	public function get initialized () : Boolean {
		return _initialized;
	}


	public function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}
	
	public function get factory () : ObjectFactory {
		return _factory;
	}
	
	
	public function getObjectCount (type:Class = null) : uint {
		checkState();
		return _registry.getDefinitionCount(type);
	}
	
	public function getObjectIds (type:Class = null) : Array {
		checkState();
		return _registry.getDefinitionIds(type);
	}
	
	
	public function containsObject (id:String) : Boolean {
		checkState();
		return _registry.containsDefinition(id);
	}
	
	public function getObject (id:String) : Object {
		checkState();
		return getInstance(getDefinition(id));
	}
	
	public function getType (id:String) : Class {
		checkState();
		var def:ObjectDefinition = getDefinition(id);
		return def.type.getClass();
	}
	
	
	public function getAllObjectsByType (type:Class) : Array {
		checkState();
		var defs:Array = _registry.getAllDefinitionsByType(type);
		var objects:Array = new Array();
		for each (var def:RootObjectDefinition in defs) {
			objects.push(getInstance(def));
		}
		return defs;
	}
	
	public function getObjectByType (type:Class, required:Boolean = false) : Object {
		checkState();
		var def:RootObjectDefinition = _registry.getDefinitionByType(type, required);
		if (def == null && required) {
			throw new ContextError("Context does not contain an object of type " + getQualifiedClassName(type));
		}
		return (def != null) ? getInstance(def) : null;
	}
	

	/**
	 * @private
	 */
	internal function getInstance (def:RootObjectDefinition) : Object {
		var id:String = def.id;
		
		if (def.singleton && singletonCache.containsKey(id)) {
			return singletonCache.get(id);
		}		
		
		if (underConstruction[id]) {
			throw new ContextError("Illegal type of bidirectional association. Make sure that at least" +
					" one side is a singleton, at most one side uses the constructor for injection and" +
					" none of the objects involved is a factory.");
		}
		underConstruction[id] = true;
		
		try {
			var instance:Object = _factory.createObject(def, this);
			if (def.singleton) {
				singletonCache.put(id, instance);
				if (!initialized && def.asyncInitConfig != null && asyncInitSequence != null) {
					asyncInitSequence.addInstance(def, instance);
				}
			}
			_factory.configureObject(instance, def, this);
		}
		finally {
			delete underConstruction[id];
		}
		return instance;
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

	public function destroy () : void {
		if (_destroyed) {
			return;
		}
		if (asyncInitSequence != null) {
			asyncInitSequence.cancel();
			asyncInitSequence = null;
		}
		try {
			dispatchEvent(new ContextEvent(ContextEvent.DESTROYED));
		}
		finally {
			_destroyed = true;
		}
	}
	
	public function get destroyed () : Boolean {
		return _destroyed;
	}
	
	private function contextDestroyed (event:Event) : void {
		if (_configured) {
			_factory.destroyAll(this);
		}
		_configured = false;
		_initialized = false;
		_registry = null;
		_factory = null;
		_messageRouter = null;
	}

	public function get messageRouter () : MessageRouter {
		return _messageRouter;
	}
	
	
	private function checkState () : void {
		if (!_configured) {
			throw new IllegalStateError("Attempt to access Context before it was fully configured");
		}
		if (_destroyed) {
			throw new IllegalStateError("Attempt to access Context after it was destroyed");
		}
	}
	
	
}

}
