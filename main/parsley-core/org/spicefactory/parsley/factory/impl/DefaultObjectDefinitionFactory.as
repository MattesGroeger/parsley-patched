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

package org.spicefactory.parsley.factory.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.builder.MetadataDecoratorExtractor;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.FactoryObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class DefaultObjectDefinitionFactory implements ObjectDefinitionFactory {

	
	public var type:Class = Object;
	
	
	public var id:String;
	
	public var lazy:Boolean = false;
	
	public var singleton:Boolean = true;
	
	
	public var decorators:Array = new Array();
	
	
	function DefaultObjectDefinitionFactory (type:Class, id:String = null, lazy:Boolean = false, singleton:Boolean = true) {
		this.type = type;
		this.id = id;
		this.lazy = lazy;
		this.singleton = singleton;
	}

	
	public function createRootDefinition (registry:ObjectDefinitionRegistry) : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:RootObjectDefinition = new DefaultRootObjectDefinition(ci, id, lazy, singleton);
		def = processDecorators(registry, def) as RootObjectDefinition;
		return def;
	}
	
	public function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:ObjectDefinition = new DefaultObjectDefinition(ci);
		def = processDecorators(registry, def);
		return def;
	}
	
	
	protected function processDecorators (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var decorators:Array = MetadataDecoratorExtractor.extract(definition.type).concat(this.decorators);
		for each (var decorator:ObjectDefinitionDecorator in decorators) {
			var newDef:ObjectDefinition = decorator.decorate(definition, registry);
			if (newDef != definition) {
				validateDefinitionReplacement(definition, newDef, decorator);
				definition = newDef;
			}
			// TODO - collect errors for ProblemReporter
		}
		return (definition is FactoryObjectDefinition) ? FactoryObjectDefinition(definition).targetDefinition : definition;
	}

	private function validateDefinitionReplacement (oldDef:ObjectDefinition, newDef:ObjectDefinition, 
			decorator:ObjectDefinitionDecorator) : void {
		// we cannot allow "downgrades"
		if (oldDef is FactoryObjectDefinition && (!(newDef is FactoryObjectDefinition))) {
			throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
					+ " attempts to downgrade a FactoryObjectDefinition to " + getQualifiedClassName(newDef));
		}
		if (oldDef is RootObjectDefinition && (!(newDef is RootObjectDefinition))) {
			throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
					+ " attempts to downgrade a RootObjectDefinition to " + getQualifiedClassName(newDef));
		}
	}
	
	
}
}
