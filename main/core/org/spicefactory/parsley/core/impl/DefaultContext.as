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
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.messaging.MessageDispatcher;
import org.spicefactory.parsley.messaging.impl.DefaultMessageDispatcher;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultContext implements Context {


	private var _registry:ObjectDefinitionRegistry;
	private var _factory:ObjectFactory;
	private var _messageDispatcher:MessageDispatcher;
	
	private var _singletonCache:SimpleMap;
	private var _factoryCache:SimpleMap;
	private var _destroyCommands:CommandChain; // TODO - maybe use events instead of commands
	
	private var _underConstruction:Dictionary = new Dictionary();
	private var _destroyed:Boolean;
	
	
	function DefaultContext (registry:ObjectDefinitionRegistry = null, 
			dispatcher:MessageDispatcher = null,
			factory:ObjectFactory = null) {
		_registry = (registry != null) ? registry : new DefaultObjectDefinitionRegistry();
		_messageDispatcher = (dispatcher != null) ? dispatcher : new DefaultMessageDispatcher();
		_factory = (factory != null) ? factory : new DefaultObjectFactory();
	}

	
	public function initialize () : void {
		// TODO - must process new definitions (create non-lazy singletons and process message targets of lazy singletons)
	}


	public function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}
	
	public function get objectCount () : uint {
		return _registry.definitionCount;
	}
	
	public function get objectIds () : Array {
		return _registry.definitionIds;
	}
	
	public function containsObject (id:String) : Boolean {
		return _registry.containsDefinition(id);
	}
	
	public function getType (id:String) : Class {
		var def:ObjectDefinition = getDefinition(id);
		return (def.factoryMethod == null) ? def.type.getClass() : def.factoryMethod.returnType.getClass();
	}
	
	public function getObjectsByType (type:Class) : Array {
		var defs:Array = _registry.getDefinitionsByType(type);
		var objects:Array = new Array();
		for each (var def:RootObjectDefinition in defs) {
			objects.push(getInstance(def));
		}
		return defs;
	}
	
	public function getObject (id:String) : Object {
		return getInstance(getDefinition(id));
	}
	
	public function getFactory (id:String) : Object {
		return getInstance(getDefinition(id), true);		
	}
	
	private function getInstance (def:RootObjectDefinition, getFactory:Boolean = false) : Object {
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
			var isFactory:Boolean = (def.factoryMethod != null);
			var instance:Object;
			if (isFactory && _factoryCache.containsKey(id)) {
				instance = _factoryCache.get(id);
			}
			else {
				instance = _factory.createObject(def, this);
				if (isFactory) {
					_factoryCache.put(id, instance);
				}
				else if (def.singleton) {
					_singletonCache.put(id, instance);
				}
				
				_factory.configureObject(instance, def, this, (!def.singleton || !def.lazy));
			}
			
			if (isFactory && !getFactory) {
				instance = def.factoryMethod.invoke(instance, []);
				if (instance == null) {
					throw new ContextError("Factory with id " + id + " returned null");
				}
				if (def.singleton) {
					_singletonCache.put(id, instance);
				}
			}
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
	
	
	public function addDestroyCommand (com:Command) : void {
		_destroyCommands.addCommand(com);		
	}
	
	public function destroy () : void {
		if (_destroyed) {
			return;
		}
		try {
			_destroyCommands.execute();
			_destroyCommands = null;
		}
		finally {
			_destroyed = true;
		}
	}
	
	public function get messageDispatcher () : MessageDispatcher {
		return _messageDispatcher;
	}
	
	
}

}
