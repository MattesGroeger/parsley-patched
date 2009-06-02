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

package org.spicefactory.parsley.registry.impl {
	import org.spicefactory.parsley.registry.impl.DefaultRootObjectDefinition;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.builder.MetadataDecoratorExtractor;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.registry.FactoryObjectDefinition;
import org.spicefactory.parsley.registry.ObjectDefinition;
import org.spicefactory.parsley.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.registry.RootObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

import flash.utils.getQualifiedClassName;

[DefaultProperty("decorators")]

/**
 * Default implementation of the ObjectDefinitionFactory interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectDefinitionFactory implements ObjectDefinitionFactory {

	
	private static const log:Logger = LogContext.getLogger(DefaultObjectDefinitionFactory);

	
	public var type:Class = Object;
	
	/**
	 * @copy ObjectDefinitionMetadata#id
	 */
	public var id:String;
	
	/**
	 * @copy ObjectDefinitionMetadata#lazy
	 */
	public var lazy:Boolean = false;
	
	/**
	 * @copy ObjectDefinitionMetadata#singleton
	 */
	public var singleton:Boolean = true;
	
	
	/**
	 * The ObjectDefinitionDecorator instances added to this definition.
	 */
	public var decorators:Array = new Array();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type this factory should create a definition for
	 * @param id the id the object should be registered with
	 * @param lazy whether the object is lazy initializing
	 * @param singleton whether the object should be treated as a singleton
	 */
	function DefaultObjectDefinitionFactory (type:Class, id:String = null, lazy:Boolean = false, singleton:Boolean = true) {
		this.type = type;
		this.id = id;
		this.lazy = lazy;
		this.singleton = singleton;
	}

	
	/**
	 * @inheritDoc
	 */
	public function createRootDefinition (registry:ObjectDefinitionRegistry) : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:RootObjectDefinition = new DefaultRootObjectDefinition(ci, id, lazy, singleton);
		def = processDecorators(registry, def) as RootObjectDefinition;
		return def;
	}
	
	/**
	 * @inheritDoc
	 */
	public function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var ci:ClassInfo = ClassInfo.forClass(type, registry.domain);
		var def:ObjectDefinition = new DefaultObjectDefinition(ci);
		def = processDecorators(registry, def);
		return def;
	}
	
	
	/**
	 * Processes the decorators for this factory. This implementation processes decorators added
	 * as metadata to the class definitions along with decorators added to the <code>decorators</code>
	 * property explicitly, possibly through some additional configuration mechanism like MXML or XML.
	 * 
	 * @param registry the registry the defintion belongs to
	 * @param definition the definition to process
	 * @param definition the resulting definition (possibly the same instance that was passed to this method)
	 */
	protected function processDecorators (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var decorators:Array = MetadataDecoratorExtractor.extract(definition.type).concat(this.decorators);
		var errors:Array = new Array();
		for each (var decorator:ObjectDefinitionDecorator in decorators) {
			try {
				var newDef:ObjectDefinition = decorator.decorate(definition, registry);
				if (newDef != definition) {
					validateDefinitionReplacement(definition, newDef, decorator);
					definition = newDef;
				}
			}
			catch (e:Error) {
				var msg:String = "Error applying " + decorator;
				log.error(msg + "{0}", e);
				errors.push(msg + ": " + e.message);
			}
		}
		if (errors.length > 0) {
			throw new ContextError("One or more errors processing " + definition + ":\n " + errors.join("\n "));
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
