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

package org.spicefactory.parsley.factory.decorator {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.impl.MetadataObjectDefinitionBuilder;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionHolder;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultRootObjectDefinition;

/**
 * @author Jens Halm
 */
[Metadata(name="Factory", types="method")]
public class FactoryMethodDecorator implements ObjectDefinitionDecorator {


	public var method:Method;


	public function decorate (definitionHolder:ObjectDefinitionHolder, registry:ObjectDefinitionRegistry) : void {
		
		var definition:ObjectDefinition = definitionHolder.processedDefinition;
		// Specified definition is for the factory, must be registered as a root factory, 
		// even if the original definition is for a nested object
		var factoryDefinition:RootObjectDefinition = DefaultRootObjectDefinition.fromDefinition(definition);
		registry.registerDefinition(factoryDefinition);
		definitionHolder.processedDefinition = factoryDefinition;
		
		// Must create a new definition for the target type
		var targetDefinition:ObjectDefinition = (definition is RootObjectDefinition) 
				? MetadataObjectDefinitionBuilder.newRootDefinition(registry, method.returnType.getClass()) 
				: MetadataObjectDefinitionBuilder.newDefinition(registry, method.returnType.getClass());
		targetDefinition.instantiator = new FactoryMethodInstantiator(factoryDefinition, method);
		definitionHolder.targetDefinition = targetDefinition;
				
	}
	
	
}
}

import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.ObjectInstantiator;
import org.spicefactory.parsley.factory.RootObjectDefinition;

class FactoryMethodInstantiator implements ObjectInstantiator {

	
	private var definition:RootObjectDefinition;
	private var method:Method;


	function FactoryMethodInstantiator (definition:RootObjectDefinition, method:Method) {
		this.definition = definition;
		this.method = method;
	}

	
	public function instantiate (context:Context) : Object {
		var factory:Object = context.getObject(definition.id);
		if (factory == null) {
			throw new ContextError("Unable to obtain factory of type " + definition.type.name);
		}
		return method.invoke(factory, []);
	}
	
	
}
