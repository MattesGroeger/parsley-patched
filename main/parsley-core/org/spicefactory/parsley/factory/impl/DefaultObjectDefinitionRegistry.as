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
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class DefaultObjectDefinitionRegistry implements ObjectDefinitionRegistry {
	
	
	private var _domain:ApplicationDomain;
	
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
		if (definitions.containsKey(definition.id)) {
			throw new IllegalArgumentError("Duplicate id for object definition: " + definition.id);
		}
		definitions.put(definition.id, definition);
	}

	public function unregisterDefinition (definition:RootObjectDefinition) : void {
		if (containsDefinition(definition.id)) {
			if (getDefinition(definition.id) != definition) {
				throw new IllegalArgumentError("Definition with id " + definition.id 
						+ " is not identical with a different definition with the same id and cannot be removed");	
			}
			definitions.remove(definition.id);
		}
	}
	
	public function get definitionCount () : uint {
		return definitions.getSize();
	}
	
	public function get definitionIds () : Array {
		return definitions.keys;
	}
	
	public function getDefinitionsByType (type:Class) : Array {
		var defs:Array = new Array();
		for each (var def:RootObjectDefinition in definitions.values) {
			if (def.type.isType(type)) {
				defs.push(def);
			}
		}
		return defs;
	}
	
	
}

}
