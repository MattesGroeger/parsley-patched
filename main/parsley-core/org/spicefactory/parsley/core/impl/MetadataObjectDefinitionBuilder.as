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
import org.spicefactory.parsley.core.errors.ContextError;
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

import flash.utils.getQualifiedClassName;/**
 * @author Jens Halm
 */
public class MetadataObjectDefinitionBuilder {
	
	
	
	public function newRootDefinition (registry:ObjectDefinitionRegistry, type:Class, id:String = null, 
			lazy:Boolean = true, singleton:Boolean = true) : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:RootObjectDefinition = new DefaultRootObjectDefinition(ci, id, lazy, singleton);
		def = processMetadata(registry, def) as RootObjectDefinition;
		registry.registerDefinition(def);
		return def;
	}
	
	public function newDefinition (registry:ObjectDefinitionRegistry, type:Class) : ObjectDefinition {
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:ObjectDefinition = new DefaultObjectDefinition(ci);
		def = processMetadata(registry, def);
		return def;
	}

	public function processMetadata (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var type:ClassInfo = definition.type;
		
		definition = executeMetadataHandlers(registry, definition, type);
		for each (var property:Property in type.getProperties()) {
			definition = executeMetadataHandlers(registry, definition, property);
		}
		for each (var method:Method in type.getMethods()) {
			definition = executeMetadataHandlers(registry, definition, method);
		}
		
		return (definition is FactoryObjectDefinition) ? FactoryObjectDefinition(definition).targetDefinition : definition;
	}

	private function executeMetadataHandlers (registry:ObjectDefinitionRegistry, 
			definition:ObjectDefinition, type:MetadataAware) : ObjectDefinition {
		for each (var metadata:Object in type.getAllMetadata()) {
			if (metadata is ObjectDefinitionDecorator) {
				definition = applyDecorator(definition, metadata as ObjectDefinitionDecorator, registry);
			} 
		}
		return definition;
	}
	
	protected function applyDecorator (definition:ObjectDefinition, 
			decorator:ObjectDefinitionDecorator, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		// TODO - map Property and Method instances
		var newDef:ObjectDefinition = decorator.decorate(definition, registry);
		if (newDef != definition) {
			// we cannot allow "downgrades"
			if (definition is FactoryObjectDefinition && (!(newDef is FactoryObjectDefinition))) {
				throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
						+ " attempts to downgrade a FactoryObjectDefinition to " + getQualifiedClassName(newDef));
			}
			if (definition is RootObjectDefinition && (!(newDef is RootObjectDefinition))) {
				throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
						+ " attempts to downgrade a RootObjectDefinition to " + getQualifiedClassName(newDef));
			}
		}				
		return newDef;
		// TODO - collect errors for ProblemReporter		
	}
	
	
}
}
