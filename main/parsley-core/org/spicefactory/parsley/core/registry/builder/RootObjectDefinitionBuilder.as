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
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;

/**
 * Builder for creating root object definitions.
 * 
 * @author Jens Halm
 */
public interface RootObjectDefinitionBuilder {
	
	
	/**
	 * Sets the id the object should be registered with.
	 * 
	 * @param id the id the object should be registered with
	 * @return this builder instance for method chaining
	 */
	function setId (id:String) : RootObjectDefinitionBuilder;
	
	/**
	 * Indicates whether this object should be lazily initialized.
	 * If set to false (the default) the object will be instantiated upon Context initialization.
	 * 
	 * @param lazy indicates whether this object should be lazily initialized
	 * @return this builder instance for method chaining
	 */
	function setLazy (lazy:Boolean) : RootObjectDefinitionBuilder;

	/**
	 * Indicates whether the Context should cache instances of this object internally
	 * and return the cached instance on subsequent requests. If set to false the
	 * Context will create a new instance on each request. The default is true.
	 * 
	 * @param singleton indicates whether this definition represents a singleton
	 * @return this builder instance for method chaining
	 */
	function setSingleton (singleton:Boolean) : RootObjectDefinitionBuilder;

	/**
	 * Sets the processing order for this object upon Context creation.
	 * Only has an effect for non-lazy singletons. 
	 * 
	 * @param order the processing order for this object upon Context creation
	 * @return this builder instance for method chaining
	 */
	function setOrder (order:int) : RootObjectDefinitionBuilder;

	/**
	 * Sets the object responsible for creating instances from this definition.
	 * If this property is not null the <code>constructorArgs</code> will be ignored.
	 * 
	 * @param instantiator the object responsible for creating instances from this definition
	 * @return this builder instance for method chaining
	 */
	function setInstantiator (instantiator:ObjectInstantiator) : RootObjectDefinitionBuilder;
	
	/**
	 * Adds a decorator to be processed when creating the definition.
	 * This decorator will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param decorator the decorator to add to this builder
	 * @return this builder instance for method chaining
	 */
	function addDecorator (decorator:ObjectDefinitionDecorator) : RootObjectDefinitionBuilder;

	/**
	 * Adds decorators to be processed when creating the definition.
	 * Thess decorators will be processed in addition to any decorators assembled by the
	 * DecoratorAssemblers registered with the ObjectDefinitionRegistry.
	 * 
	 * @param decorators the decorators to add to this builder
	 * @return this builder instance for method chaining
	 */
	function addAllDecorators (decorators:Array) : RootObjectDefinitionBuilder;
	
	/**
	 * Builds a new definition using all parameters set through other methods.
	 * 
	 * @return a new root object definition
	 */
	function build () : RootObjectDefinition;
	
	
}
}
