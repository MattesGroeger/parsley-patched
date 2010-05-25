/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.dsl.core.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.config.DecoratorAssembler;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.errors.ObjectDefinitionError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.impl.AbstractObjectDefinition;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.dsl.impl.ObjectDefinitionContext;

/**
 * Base class for builders that create the final definitions for singletons or dynamic objects.
 * 
 * @author Jens Halm
 */
public class AbstractTargetDefinitionBuilder {
	
	
	private static var log:Logger = LogContext.getLogger(AbstractTargetDefinitionBuilder);

	/**
	 * The context for this builder.
	 */
	protected var context:ObjectDefinitionContext;
	
	private var builder:ObjectDefinitionBuilder;
	private var legacyHandler:LegacyDecoratorHandler = new LegacyDecoratorHandler();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the context for this builder
	 * @param builder the root builder 
	 */
	function AbstractTargetDefinitionBuilder (context:ObjectDefinitionContext, builder:ObjectDefinitionBuilder) {
		this.context = context;
		this.builder = builder;
	}
	
	
	/**
	 * Processes the specified definition, including all associated decorators. 
	 * 
	 * @param definition the definition to process
	 * @param additionalDecorators decorators to add to the ones extracted by the standard assemblers
	 * @return the resulting definition (possibly the same instance that was passed to this method)
	 */
	public function processDefinition (definition:AbstractObjectDefinition, additionalDecorators:Array) : ObjectDefinition {
		
		processDecorators(definition, additionalDecorators);
		
		return context.processDefinition(definition);
		
		// TODO - move entire class to DefaultObjectDefinitionContext

	}
	
	/**
	 * Processes the decorators for this builder. This implementation processes all decorators obtained
	 * through the decorator assemblers registered for the core <code>Configuration</code> instance 
	 * (usually one assembler processing metadata tags)
	 * along with decorators which were explicitly added, 
	 * possibly through some additional configuration mechanism like MXML or XML.
	 * 
	 * @param definition the definition to process
	 * @param additionalDecorators decorators to add to the ones extracted by the standard assemblers
	 * @return the resulting definition (possibly the same instance that was passed to this method)
	 */
	protected function	processDecorators (definition:AbstractObjectDefinition, additionalDecorators:Array) : void {
		var decorators:Array = new Array();
		for each (var assembler:DecoratorAssembler in context.assemblers) {
			decorators = decorators.concat(assembler.assemble(definition.type));
		}
		decorators = decorators.concat(additionalDecorators);
		
		var errors:Array = new Array();
		for each (var decorator:Object in decorators) {
			try {
				if (!legacyHandler.processDecorator(decorator, definition, context)) {
					ObjectDefinitionDecorator(decorator).decorate(builder);
				}
			}
			catch (e:Error) {
				log.error("Error applying {0}: {1}", decorator, e);
				errors.push(e);
			}
		}
		if (errors.length > 0) {
			throw new ObjectDefinitionError(definition, errors);
		} 
	}
	
	
}
}


import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.dsl.core.ObjectDefinitionReplacer;
import org.spicefactory.parsley.dsl.impl.ObjectDefinitionContext;

class LegacyDecoratorHandler {
	
	
	public function	processDecorator (object:Object, definition:ObjectDefinition, context:ObjectDefinitionContext) : Boolean {
				
		if (!(object is ObjectDefinitionDecorator)) {
			return false;
		}
		
		var decorator:ObjectDefinitionDecorator = ObjectDefinitionDecorator(object);
		var finalDefinition:ObjectDefinition = decorator.decorate(definition, context.config.registry);
		if (definition != finalDefinition) {
			context.setDefinitionReplacer(new SimpleDefinitionReplacer(finalDefinition));
		}
		return true;
	}
	
	
}

class SimpleDefinitionReplacer implements ObjectDefinitionReplacer {

	private var replacement:ObjectDefinition;

	function SimpleDefinitionReplacer (replacement:ObjectDefinition) {
		this.replacement = replacement;
	}

	public function replace (definition:ObjectDefinition) : ObjectDefinition {
		return replacement;
	}
	
}
 

