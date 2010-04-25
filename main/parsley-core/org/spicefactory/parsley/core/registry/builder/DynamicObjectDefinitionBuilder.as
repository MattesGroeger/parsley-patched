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

package org.spicefactory.parsley.core.registry.builder {
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;

/**
 * Builder for creating dynamic object definitions.
 * 
 * @author Jens Halm
 */
public interface DynamicObjectDefinitionBuilder {
	
	
	/**
	 * Sets the optional id to use when matching this configuration with
	 * a dynamically wired view instance. Usually the name of the component
	 * will be used to match against this id.
	 * 
	 * @param value the id that should be used for matching dynamically wired views
	 * @return this builder instance for method chaining
	 */
	function id (value:String) : DynamicObjectDefinitionBuilder;

	/**
	 * Adds a decorator to be processed when creating the definition.
	 * This decorator will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param value the decorator to add to this builder
	 * @return this builder instance for method chaining
	 */
	function decorator (value:ObjectDefinitionDecorator) : DynamicObjectDefinitionBuilder;

	/**
	 * Adds decorators to be processed when creating the definition.
	 * These decorators will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param value the decorators to add to this builder
	 * @return this builder instance for method chaining
	 */
	function decorators (value:Array) : DynamicObjectDefinitionBuilder;
	
	/**
	 * Sets the object responsible for creating instances from this definition.
	 * If this property is not null the <code>constructorArgs</code> will be ignored.
	 * 
	 * @param value the object responsible for creating instances from this definition
	 * @return this builder instance for method chaining
	 */
	function instantiator (value:ObjectInstantiator) : DynamicObjectDefinitionBuilder;
	
	/**
	 * Builds a new definition using all parameters set through other methods.
	 * With this method the returned definition will not be registered
	 * with the registry associated with this builder.
	 * 
	 * @return a new view object definition
	 */
	function build () : DynamicObjectDefinition;
	
	/**
	 * Builds a new definition using all parameters set through the other methods of this builder
	 * and registers it with the registry associated with this builder.
	 * 
	 * @return a new view object definition
	 */
	function buildAndRegister () : DynamicObjectDefinition;
	
	
}
}
