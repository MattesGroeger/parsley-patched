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

package org.spicefactory.parsley.factory.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

import flash.system.ApplicationDomain;
import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class DefaultObjectDefinitionRegistry implements ObjectDefinitionRegistry {
	
	
	private var _domain:ApplicationDomain;
	
	private var _frozen:Boolean;
	
	private var definitions:SimpleMap = new SimpleMap();


	function DefaultObjectDefinitionRegistry (domain:ApplicationDomain = null) {
		_domain = domain;
	}

	
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	
	public function containsDefinition (id:String) : Boolean {
		return definitions.containsKey(id);
	}
	
	public function getDefinition (id:String) : RootObjectDefinition {
		return definitions.get(id) as RootObjectDefinition;
	}

	public function registerDefinition (definition:RootObjectDefinition) : void {
		checkState();
		if (definitions.containsKey(definition.id)) {
			throw new IllegalArgumentError("Duplicate id for object definition: " + definition.id);
		}
		definitions.put(definition.id, definition);
	}

	public function unregisterDefinition (definition:RootObjectDefinition) : void {
		checkState();
		if (containsDefinition(definition.id)) {
			if (getDefinition(definition.id) != definition) {
				throw new IllegalArgumentError("Definition with id " + definition.id 
						+ " is not identical with a different definition with the same id and cannot be removed");	
			}
			definitions.remove(definition.id);
		}
	}
	
	public function getDefinitionCount (type:Class = null) : uint {
		if (type == null) {
			return definitions.getSize();
		}
		else {
			return getAllDefinitionsByType(type).length;
		}
	}
	
	public function getDefinitionIds (type:Class = null) : Array {
		if (type == null) {
			return definitions.keys;
		}
		else {
			return getAllDefinitionsByType(type).map(idMapper);
		}
	}
	
	
	public function getDefinitionByType (type:Class, required:Boolean = false) : RootObjectDefinition {
		var defs:Array = getAllDefinitionsByType(type);
		if (defs.length > 1) {
			throw new IllegalArgumentError("More than one object of type " + getQualifiedClassName(type) 
					+ " was registered");
		}
		else if (required && defs.length == 0) {
			throw new IllegalArgumentError("No object of type " + getQualifiedClassName(type) 
					+ " was registered");
		}
		return (defs.length == 0) ? null : defs[0];
	}
	
	public function getAllDefinitionsByType (type:Class) : Array {
		return definitions.values.filter(getTypeFilter(type));
	}
	
	
	private function getTypeFilter (type:Class) : Function {
		return function (definition:ObjectDefinition, index:int, array:Array) : Boolean {
			return (definition.type.isType(type));
		};
	}
	
	private function idMapper (definition:RootObjectDefinition, index:int, array:Array) : String {
		return definition.id;
	}
	
	
	public function freeze () : void {
		_frozen = true;
		for each (var definition:ObjectDefinition in definitions.values) {
			definition.freeze();
		}
	}
	
	public function get frozen () : Boolean {
		return _frozen;
	}
	
	private function checkState () : void {
		if (_frozen) {
			throw new IllegalStateError("Registry is frozen");
		}
	}
	
	
}

}
