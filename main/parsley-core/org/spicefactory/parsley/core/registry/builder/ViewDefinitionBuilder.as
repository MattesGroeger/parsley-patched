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
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;

/**
 * Builder for creating view object definitions.
 * 
 * @author Jens Halm
 */
public interface ViewDefinitionBuilder {
	
	
	/**
	 * Sets the optional id to use when matching this configuration with
	 * a dynamically wired view instance. Usually the name of the component
	 * will be used to match against this id.
	 * 
	 * @param id the id that should be used for matching dynamically wired views
	 * @return this builder instance for method chaining
	 */
	function setId (id:String) : ViewDefinitionBuilder;

	/**
	 * Adds a decorator to be processed when creating the definition.
	 * This decorator will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param decorator the decorator to add to this builder
	 * @return this builder instance for method chaining
	 */
	function addDecorator (decorator:ObjectDefinitionDecorator) : ViewDefinitionBuilder;

	/**
	 * Adds decorators to be processed when creating the definition.
	 * Thess decorators will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param decorators the decorators to add to this builder
	 * @return this builder instance for method chaining
	 */
	function addAllDecorators (decorators:Array) : ViewDefinitionBuilder;
	
	/**
	 * Builds a new definition using all parameters set through other methods.
	 * 
	 * @return a new view object definition
	 */
	function build () : ObjectDefinition;
	
	
}
}
