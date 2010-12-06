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

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.InitializingService;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.context.provider.ObjectProviderFactory;
import org.spicefactory.parsley.core.events.ObjectDefinitionRegistryEvent;
import org.spicefactory.parsley.core.registry.ConfigurationProperties;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.builder.ObjectDefinitionBuilderFactory;
import org.spicefactory.parsley.core.registry.builder.impl.DefaultObjectDefinitionBuilderFactory;
import org.spicefactory.parsley.core.scope.ScopeManager;

import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.getQualifiedClassName;

/**
 * Default implementation of the ObjectDefinitionRegistry interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectDefinitionRegistry extends EventDispatcher implements ObjectDefinitionRegistry, InitializingService {
	
	
	private var _domain:ApplicationDomain;
	private var _decoratorAssemblers:Array;
	private var _context:Context;
	
	private var _properties:ConfigurationProperties;
	private var _builders:ObjectDefinitionBuilderFactory;
	
	private var _frozen:Boolean;
	
	private var definitions:SimpleMap = new SimpleMap();

	/* Deprecated */
	private var objectProviderFactory:ObjectProviderFactory;


	/**
	 * Creates a new instance.
	 */
	function DefaultObjectDefinitionRegistry () {
		
	}

	
	/**
	 * @inheritDoc
	 */
	public function init (info:BootstrapInfo) : void {
		_domain = info.domain;
		_context = info.context;
		_decoratorAssemblers = [];
		this.objectProviderFactory = info.objectProviderFactory;
		_properties = new DefaultProperties();
		_builders = new DefaultObjectDefinitionBuilderFactory(this);
	}
	
	/**
	 * @inheritDoc
	 */	
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	/**
	 * @inheritDoc
	 */	
	public function get properties () : ConfigurationProperties {
		return _properties;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get decoratorAssemblers () : Array {
		return _decoratorAssemblers.concat();
	}

	/**
	 * @inheritDoc
	 */
	public function get scopeManager () : ScopeManager {
		return _context.scopeManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get context () : Context {
		return _context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function containsDefinition (id:String) : Boolean {
		return definitions.containsKey(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getDefinition (id:String) : ObjectDefinition {
		return definitions.get(id) as ObjectDefinition;
	}

	/**
	 * @inheritDoc
	 */
	public function registerDefinition (definition:ObjectDefinition) : void {
		checkState();
		if (definitions.containsKey(definition.id)) {
			throw new IllegalArgumentError("Duplicate id for object definition: " + definition.id);
		}
		definitions.put(definition.id, definition);
	}
	
	/**
	 * @inheritDoc
	 */
	public function unregisterDefinition (definition:ObjectDefinition) : void {
		checkState();
		if (containsDefinition(definition.id)) {
			if (getDefinition(definition.id) != definition) {
				throw new IllegalArgumentError("Definition with id " + definition.id 
						+ " is not identical with a different definition with the same id and cannot be removed");	
			}
			definitions.remove(definition.id);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get builders () : ObjectDefinitionBuilderFactory {
		return _builders;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getDefinitionCount (type:Class = null) : uint {
		if (type == null) {
			return definitions.getSize();
		}
		else {
			return getAllDefinitionsByType(type).length;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function getDefinitionIds (type:Class = null) : Array {
		if (type == null) {
			return definitions.keys;
		}
		else {
			return getAllDefinitionsByType(type).map(idMapper);
		}
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function getDefinitionByType (type:Class) : ObjectDefinition {
		var defs:Array = getAllDefinitionsByType(type);
		if (defs.length > 1) {
			throw new IllegalArgumentError("More than one object of type " + getQualifiedClassName(type) 
					+ " was registered");
		}
		else if (defs.length == 0) {
			throw new IllegalArgumentError("No object of type " + getQualifiedClassName(type) 
					+ " was registered");
		}
		return defs[0];
	}
	
	/**
	 * @inheritDoc
	 */
	public function getAllDefinitionsByType (type:Class) : Array {
		return definitions.values.filter(getTypeFilter(type));
	}
	
	
	private function getTypeFilter (type:Class) : Function {
		return function (definition:ObjectDefinition, index:int, array:Array) : Boolean {
			return (definition.type.isType(type));
		};
	}
	
	private function idMapper (definition:ObjectDefinition, index:int, array:Array) : String {
		return definition.id;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function freeze () : void {
		_frozen = true;
		for each (var definition:ObjectDefinition in definitions.values) {
			definition.freeze();
		}
		dispatchEvent(new ObjectDefinitionRegistryEvent(ObjectDefinitionRegistryEvent.FROZEN));
	}
	
	/**
	 * @inheritDoc
	 */
	public function get frozen () : Boolean {
		return _frozen;
	}
	
	private function checkState () : void {
		if (_frozen) {
			throw new IllegalStateError("Registry is frozen");
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function createObjectProvider (type:Class, id:String = null) : ObjectProvider {
		return objectProviderFactory.createProvider(type, id);
	}
	
}
}

import org.spicefactory.parsley.core.registry.ConfigurationProperties;

import flash.utils.Dictionary;

class DefaultProperties implements ConfigurationProperties {
	
	private var map:Dictionary = new Dictionary();

	public function setValue (name:String, value:Object) : void {
		map[name] = value;
	}
	
	public function getValue (name:String) : Object {
		return map[name];
	}
	
	public function removeValue (name:String) : void {
		delete map[name];
	}
	
}

