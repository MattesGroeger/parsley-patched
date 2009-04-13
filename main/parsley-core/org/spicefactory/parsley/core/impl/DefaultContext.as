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

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultContext extends EventDispatcher implements Context {


	private var _registry:ObjectDefinitionRegistry;
	private var _factory:ObjectFactory;
	private var _messageRouter:MessageRouter;
	
	private var _singletonCache:SimpleMap;
	
	private var _underConstruction:Dictionary = new Dictionary();
	
	private var _initialized:Boolean;
	private var _destroyed:Boolean;
	
	
	function DefaultContext (registry:ObjectDefinitionRegistry = null, 
			messageRouter:MessageRouter = null,
			factory:ObjectFactory = null) {
		_registry = (registry != null) ? registry : new DefaultObjectDefinitionRegistry();
		_messageRouter = (messageRouter != null) ? messageRouter : new DefaultMessageRouter();
		_factory = (factory != null) ? factory : new DefaultObjectFactory();
		addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}

	
	public function initialize () : Boolean {
		_registry.freeze();
		for each (var id:String in _registry.getDefinitionIds()) {
			var definition:RootObjectDefinition = _registry.getDefinition(id);
			// create singletons which are not defined as lazy
			if (definition.singleton && !definition.lazy) {
				getInstance(definition);
				// TODO - check if it contains asyncInitializers (will be executed before all [PostConstruct] methods)
			}
		}
		_initialized = true;
		return true;
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
		return _registry.getDefinitionCount(type);
	}
	
	public function getObjectIds (type:Class = null) : Array {
		return _registry.getDefinitionIds(type);
	}
	
	
	public function containsObject (id:String) : Boolean {
		return _registry.containsDefinition(id);
	}
	
	public function getObject (id:String) : Object {
		return getInstance(getDefinition(id));
	}
	
	public function getType (id:String) : Class {
		var def:ObjectDefinition = getDefinition(id);
		return def.type.getClass();
	}
	
	
	public function getAllObjectsByType (type:Class) : Array {
		var defs:Array = _registry.getAllDefinitionsByType(type);
		var objects:Array = new Array();
		for each (var def:RootObjectDefinition in defs) {
			objects.push(getInstance(def));
		}
		return defs;
	}
	
	public function getObjectByType (type:Class, required:Boolean = false) : Object {
		return getInstance(_registry.getDefinitionByType(type, required));
	}
	

	
	private function getInstance (def:RootObjectDefinition) : Object {
		var id:String = def.id;
		
		if (def.singleton && _singletonCache.containsKey(id)) {
			return _singletonCache.get(id);
		}		
		
		if (_underConstruction[id]) {
			throw new ContextError("Illegal type of bidirectional association. Make sure that at least" +
					" one side is a singleton, at most one side uses the constructor for injection and" +
					" none of the objects involved is a factory.");
		}
		_underConstruction[id] = true;
		
		try {
			var instance:Object = _factory.createObject(def, this);
			if (def.singleton) {
				_singletonCache.put(id, instance);
			}
			_factory.configureObject(instance, def, this);
		}
		finally {
			delete _underConstruction[id];
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
	
	
	public function destroy () : void {
		if (_destroyed) {
			return;
		}
		try {
			dispatchEvent(new ContextEvent(ContextEvent.DESTROYED));
		}
		finally {
			_destroyed = true;
		}
	}
	
	public function get destroyed () : Boolean {
		return _initialized;
	}
	
	private function contextDestroyed (event:Event) : void {
		_factory.destroyAll(this);
	}
	
	public function get messageRouter () : MessageRouter {
		return _messageRouter;
	}
	
	
}

}
