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
import org.spicefactory.parsley.factory.DecoratorUtil;
import org.spicefactory.parsley.factory.FactoryObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultFactoryObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;

/**
 * @author Jens Halm
 */
[Metadata(name="Factory", types="method")]
public class FactoryMethodDecorator implements ObjectDefinitionDecorator {

	
	[Target]
	public var method:String;
	
	
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		
		// Must create a new definition for the target type
		var method:Method = DecoratorUtil.getMethod(this.method, definition);
		var targetType:Class = method.returnType.getClass();
		var id:String = (definition is RootObjectDefinition) ? RootObjectDefinition(definition).id : null;
		var targetFactory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(targetType, id);
		var targetDefinition:ObjectDefinition = (definition is RootObjectDefinition) 
				? targetFactory.createRootDefinition(registry) 
				: targetFactory.createNestedDefinition(registry);
		
		// Specified definition is for the factory, must be registered as a root factory, 
		// even if the original definition is for a nested object
		var factoryDefinition:FactoryObjectDefinition 
				= DefaultFactoryObjectDefinition.fromDefinition(definition, targetDefinition);
		registry.registerDefinition(factoryDefinition);
		targetDefinition.instantiator = new FactoryMethodInstantiator(factoryDefinition, method);

		return factoryDefinition;		
	}
	
	
}
}

import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.FactoryObjectInstantiator;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinition;

class FactoryMethodInstantiator implements FactoryObjectInstantiator {

	
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
	
	public function get factoryDefinition () : ObjectDefinition {
		return definition;
	}
	
}
