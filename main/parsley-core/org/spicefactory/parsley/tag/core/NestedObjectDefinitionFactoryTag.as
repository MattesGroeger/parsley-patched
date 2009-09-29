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

package org.spicefactory.parsley.tag.core {
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;

import flash.errors.IllegalOperationError;

[DefaultProperty("decorators")]

/**
 * Tag that may be used for nested (inline) object definitions in MXML.
 * 
 * @author Jens Halm
 */
public class NestedObjectDefinitionFactoryTag implements ObjectDefinitionFactory, NestedTag {

	
	/**
	 * The type of the object.
	 */
	public var type:Class = Object;
	
	/**
	 * The ObjectDefinitionDecorator instances added to this definition.
	 */
	public var decorators:Array = new Array();	
	
	/**
	 * @private
	 */
	public function createRootDefinition (registry:ObjectDefinitionRegistry):RootObjectDefinition {
		throw new IllegalOperationError("This tag may only be used for nested object declarations");
	}
	
	/**
	 * @inheritDoc
	 */
	public function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var factory:DefaultObjectDefinitionFactory = new DefaultObjectDefinitionFactory(type);
		factory.decorators = decorators;
		return factory.createNestedDefinition(registry);
	}
	
	
}
}