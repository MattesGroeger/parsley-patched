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

package org.spicefactory.parsley.core.registry.builder.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.errors.ObjectDefinitionError;
import org.spicefactory.parsley.core.registry.DecoratorAssembler;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;

import flash.utils.getQualifiedClassName;

/**
 * Abstract base class for ObjectDefinitionBuilders that handles processing of ObjectDefinitionDecorators.
 * 
 * @author Jens Halm
 */
public class AbstractObjectDefinitionBuilder {
	
	
	
	private static const log:Logger = LogContext.getLogger(AbstractObjectDefinitionBuilder);
	
	
	
	private var _type:ClassInfo;
	private var _registry:ObjectDefinitionRegistry;
	
	/**
	 * The decorators added to this builder.
	 */
	protected var decoratorList:Array = new Array();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of object this definition represents
	 * @param registry the registry associated with this definition
	 */
	function AbstractObjectDefinitionBuilder (type:ClassInfo, registry:ObjectDefinitionRegistry) {
		_type = type;
		_registry = registry;
	}

	/**
	 * The type to create a definition for.
	 */
	protected function get type () : ClassInfo {
		return _type;
	}
	
	/**
	 * The registry this builder belongs to.
	 */
	protected function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}
	
	
	/**
	 * Processes the decorators for this factory. This implementation processes all decorators obtained
	 * through the <code>decoratorAssemblers</code> property in the specified registry (usually one assembler processing metadata tags)
	 * along with decorators added to the <code>decorators</code>
	 * property explicitly, possibly through some additional configuration mechanism like MXML or XML.
	 * 
	 * @param registry the registry the definition belongs to
	 * @param definition the definition to process
	 * @return the resulting definition (possibly the same instance that was passed to this method)
	 */
	protected function processDecorators (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var decorators:Array = new Array();
		for each (var assembler:DecoratorAssembler in registry.decoratorAssemblers) {
			decorators = decorators.concat(assembler.assemble(definition.type));
		}
		decorators = decorators.concat(this.decoratorList);
		var errors:Array = new Array();
		var finalDefinition:ObjectDefinition = definition;
		for each (var decorator:ObjectDefinitionDecorator in decorators) {
			try {
				var newDef:ObjectDefinition = decorator.decorate(definition, registry);
				if (newDef != finalDefinition) {
					validateDefinitionReplacement(definition, newDef, decorator);
					finalDefinition = newDef;
				}
			}
			catch (e:Error) {
				log.error("Error applying {0}: {1}", decorator, e);
				errors.push(e);
			}
		}
		if (errors.length > 0) {
			throw new ObjectDefinitionError(finalDefinition, errors);
		} 
		return finalDefinition;
	}

	private function validateDefinitionReplacement (oldDef:ObjectDefinition, newDef:ObjectDefinition, 
			decorator:ObjectDefinitionDecorator) : void {
		// we cannot allow "downgrades"
		if (oldDef is SingletonObjectDefinition && (!(newDef is SingletonObjectDefinition))) {
			throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
					+ " attempts to downgrade a SingletonObjectDefinition to " + getQualifiedClassName(newDef));
		}
	}
	
	
}
}
