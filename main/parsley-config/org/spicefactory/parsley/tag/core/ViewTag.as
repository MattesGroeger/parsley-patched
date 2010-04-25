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
 * Represents the root view tag for an object definition in MXML or XML configuration.
 * 
 * @author Jens Halm
 */
public class ViewTag implements RootConfigurationTag {
	
	
	/**
	 * The optional id the view definition produced by this factory should be registered with.
	 */
	public var id:String;
	
	/**
	 * The type of dynamically wired views the definition produced by this factory should be applied to.
	 */
	public var type:Class = Object;
	
	/**
	 * The ObjectDefinitionDecorator instances added to this definition.
	 */
	public var decorators:Array = new Array();
	

	/**
	 * @inheritDoc
	 */
	public function process (registry:ObjectDefinitionRegistry) : void {
		registry.builders
				.forDynamicDefinition(type)
				.id(id)
				.decorators(decorators)
				.buildAndRegister();
	}
	
	
}
}
