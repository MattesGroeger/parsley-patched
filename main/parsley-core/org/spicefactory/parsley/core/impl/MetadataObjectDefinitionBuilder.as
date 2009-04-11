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
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.FactoryObjectDefinition;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.MetadataAware;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultRootObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

/**
 * @author Jens Halm
 */
public class MetadataObjectDefinitionBuilder {
	
	
	
	public function newRootDefinition (registry:ObjectDefinitionRegistry, type:Class, id:String = null, 
			lazy:Boolean = true, singleton:Boolean = true) : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:RootObjectDefinition = new DefaultRootObjectDefinition(ci, id, lazy, singleton);
		var result:ObjectDefinition = processMetadata(registry, def);
		if (!(result is RootObjectDefinition)) {
			throw new ContextError("Metadata processing did not return a RootObjectDefinition for type " + ci.name);
		}
		def = RootObjectDefinition(result);
		registry.registerDefinition(def);
		return def;
	}
	
	public function newDefinition (registry:ObjectDefinitionRegistry, type:Class) : ObjectDefinition {
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:ObjectDefinition = new DefaultObjectDefinition(ci);
		def = processMetadata(registry, def);
		return def;
	}

	protected function processMetadata (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var type:ClassInfo = definition.type;
		
		definition = executeMetadataHandlers(registry, definition, type);
		for each (var property:Property in type.getProperties()) {
			definition = executeMetadataHandlers(registry, definition, property);
		}
		for each (var method:Method in type.getMethods()) {
			definition = executeMetadataHandlers(registry, definition, method);
		}
		
		if (definition is FactoryObjectDefinition) {
			var factory:FactoryObjectDefinition = FactoryObjectDefinition(definition);
			registry.registerDefinition(factory);
			return factory.targetDefinition;
		}
		
		return definition;
	}

	private function executeMetadataHandlers (registry:ObjectDefinitionRegistry, 
			definition:ObjectDefinition, type:MetadataAware) : ObjectDefinition {
		for each (var metadata:Object in type.getAllMetadata()) {
			if (metadata is ObjectDefinitionDecorator) {
				//applyDecorator(metadata as ObjectDefinitionDecorator, registry);
				// TODO - map Property and Method instances
				var newDef:ObjectDefinition = ObjectDefinitionDecorator(metadata).decorate(definition, registry);
				if (newDef != definition) {
					// TODO - check if applicable
				}				
				definition = newDef;
				// TODO - collect errors for ProblemReporter
			} 
		}
		return definition;
	}
}

}
