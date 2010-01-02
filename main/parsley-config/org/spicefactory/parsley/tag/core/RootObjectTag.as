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
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.tag.RootConfigurationTag;

[DefaultProperty("decorators")]

/**
 * Represents the root object tag for an object definition in MXML or XML configuration.
 * 
 * @author Jens Halm
 */
public class RootObjectTag implements RootConfigurationTag {
	
	
	/**
	 * The type of the object configured by this definition.
	 */
	public var type:Class = Object;
	
	/**
	 * @copy org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata#id
	 */
	public var id:String;
	
	/**
	 * @copy org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata#lazy
	 */
	public var lazy:Boolean = false;
	
	/**
	 * @copy org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata#singleton
	 */
	public var singleton:Boolean = true;
	
	/**
	 * @copy org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata#order
	 */
	public var order:int = int.MAX_VALUE;

	[ArrayElementType("org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator")]
	/**
	 * The ObjectDefinitionDecorator instances added to this definition.
	 */
	public var decorators:Array = new Array();
	
	
	public function process (registry:ObjectDefinitionRegistry) : void {
		registry.builders
				.forRootDefinition(type)
				.id(id)
				.lazy(lazy)
				.singleton(singleton)
				.order(order)
				.decorators(decorators)
				.buildAndRegister();
	}
	
	
}
}
