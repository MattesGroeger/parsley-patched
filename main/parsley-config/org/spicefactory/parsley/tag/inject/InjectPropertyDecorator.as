/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.tag.inject {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.model.ObjectTypeReferenceArray;

[Metadata(name="Inject", types="property")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties for which dependency injection should
 * be performed.
 *
 * @author Jens Halm
 */
public class InjectPropertyDecorator implements ObjectDefinitionDecorator {


	[DefaultProperty]
	/**
	 * The id of the dependency to inject. If this property is null,
	 * dependency injection by type will be performed.
	 */
	public var id:String;
	
	/**
	 * Indicates whether the dependency is required or optional.
	 */
	public var required:Boolean = true;
	
	/**
	 * The type to inject, only applicable for Array properties.
	 * In this case all objects with a matching type will be included.
	 */
	public var type:Class;

	[Target]
	/**
	 * The name of the property.
	 */
	public var property:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		if (type != null) {
			if (!definition.type.getProperty(property).type.isType(Array)) {
				throw new ContextError("type attribute may only be used for Array properties");
			}
			definition.properties.addValue(property, new ObjectTypeReferenceArray(ClassInfo.forClass(type, registry.domain)));
		}
		else if (id == null) {
			definition.properties.addTypeReference(property, required);
		}
		else {
			definition.properties.addIdReference(property, id, required);
		}
		return definition;
	}
	
	
}

}
