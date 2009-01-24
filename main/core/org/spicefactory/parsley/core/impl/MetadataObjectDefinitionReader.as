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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.MetadataAware;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultRootObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

/**
 * @author Jens Halm
 */
public class MetadataObjectDefinitionReader {
	
	
	
	public static function newRootDefinition (registry:ObjectDefinitionRegistry, type:Class, id:String = null, 
			lazy:Boolean = true, singleton:Boolean = true) : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var def:RootObjectDefinition 
				= new DefaultRootObjectDefinition(ClassInfo.forClass(type, registry.domain), id, lazy, singleton);
		processMetadata(registry, def);
		registry.registerDefinition(def);
		return def;
	}

	private static function processMetadata (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : void {
		var type:ClassInfo = definition.type;
		executeMetadataHandlers(registry, definition, type);
		for each (var property:Property in type.getProperties()) {
			executeMetadataHandlers(registry, definition, property);
		}
		for each (var method:Method in type.getMethods()) {
			executeMetadataHandlers(registry, definition, method);
		}
	}
	
	private static function executeMetadataHandlers (registry:ObjectDefinitionRegistry, definition:ObjectDefinition, type:MetadataAware) : void {
		for each (var metadata:Object in type.getAllMetadata()) {
			if (metadata is ObjectDefinitionDecorator) {
				// TODO - map Property and Method instances
				ObjectDefinitionDecorator(metadata).decorate(definition, registry);				
				// TODO - collect errors for ProblemReporter
			} 
		}
	}
	

}

}
