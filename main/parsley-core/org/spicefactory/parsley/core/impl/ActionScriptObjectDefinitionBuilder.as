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

package org.spicefactory.parsley.core.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.metadata.InternalProperty;
import org.spicefactory.parsley.core.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

/**
 * @author Jens Halm
 */
public class ActionScriptObjectDefinitionBuilder {
	
	
	private var builder:MetadataObjectDefinitionBuilder = new MetadataObjectDefinitionBuilder();
	
	
	public function build (containers:Array, registry:ObjectDefinitionRegistry) : void {
		for each (var container:Class in containers) {
			var ci:ClassInfo = ClassInfo.forClass(container, registry.domain);
			var containerDefinition:RootObjectDefinition 
					= builder.newRootDefinition(registry, container);
			for each (var property:Property in ci.getProperties()) {
				var internalMeta:Array = property.getMetadata(InternalProperty);
				if (internalMeta.length == 0 && property.readable) {
					var definitionMetaArray:Array = property.getMetadata(ObjectDefinitionMetadata);
					var definitionMeta:ObjectDefinitionMetadata = (definitionMetaArray.length > 0) ? 
							ObjectDefinitionMetadata(definitionMetaArray[0]) : null;
					var id:String = (definitionMeta != null) ? definitionMeta.id : property.name;
					var lazy:Boolean = (definitionMeta != null) ? definitionMeta.lazy : true;
					var singleton:Boolean = (definitionMeta != null) ? definitionMeta.singleton : true;
					var targetDefinition:RootObjectDefinition 
							= builder.newRootDefinition(registry, property.type.getClass(), id, lazy, singleton);
					targetDefinition.instantiator = new ContainerPropertyInstantiator(containerDefinition, property);
				} 
			}	
		}
	}
	
}
}


import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.ObjectInstantiator;
import org.spicefactory.parsley.factory.RootObjectDefinition;

class ContainerPropertyInstantiator implements ObjectInstantiator {

	
	private var definition:RootObjectDefinition;
	private var property:Property;


	function ContainerPropertyInstantiator (definition:RootObjectDefinition, property:Property) {
		this.definition = definition;
		this.property = property;
	}

	
	public function instantiate (context:Context) : Object {
		var factory:Object = context.getObject(definition.id);
		if (factory == null) {
			throw new ContextError("Unable to obtain factory of type " + definition.type.name);
		}
		return property.getValue(factory);
	}
	
	
}

