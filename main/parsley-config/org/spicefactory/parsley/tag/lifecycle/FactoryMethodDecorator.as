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

package org.spicefactory.parsley.tag.lifecycle {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.ObjectInstantiator;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;
import org.spicefactory.parsley.core.registry.impl.SingletonObjectDefinitionWrapper;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

[Metadata(name="Factory", types="method")]
/**
 * Represents a Metadata, MXML or XML tag that can be used to mark a method as a factory method.
 * 
 * @author Jens Halm
 */
public class FactoryMethodDecorator implements ObjectDefinitionDecorator {

	
	[Target]
	/**
	 * The name of the factory method.
	 */
	public var method:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		
		// Specified definition is for the factory, must be registered as a root factory, 
		// even if the original definition is for a nested object
		var factoryDefinition:SingletonObjectDefinition = new SingletonObjectDefinitionWrapper(definition);
		registry.registerDefinition(factoryDefinition);
		
		// Must create a new definition for the target type
		var method:Method = ReflectionUtil.getMethod(this.method, definition);
		var targetType:Class = method.returnType.getClass();
		var instantiator:ObjectInstantiator 
				= new FactoryMethodInstantiator(factoryDefinition, method);
				
		if (definition is SingletonObjectDefinition) {
			var singletonDefinition:SingletonObjectDefinition = SingletonObjectDefinition(definition);
			return registry.builders
					.forSingletonDefinition(targetType)
					.id(singletonDefinition.id)
					.lazy(singletonDefinition.lazy)
					.instantiator(instantiator)
					.build();
		}
		else {
			return registry.builders
					.forDynamicDefinition(targetType)
					.instantiator(instantiator)
					.build();
		}
	}
}
}

import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectInstantiator;

class FactoryMethodInstantiator implements ObjectInstantiator {

	
	private var definition:ObjectDefinition;
	private var method:Method;


	function FactoryMethodInstantiator (definition:ObjectDefinition, method:Method) {
		this.definition = definition;
		this.method = method;
	}

	
	public function instantiate (target:ManagedObject) : Object {
		var factory:Object = target.context.getObject(definition.id);
		if (factory == null) {
			throw new ContextError("Unable to obtain factory of type " + definition.type.name);
		}
		var instance:Object = method.invoke(factory, []);
		if (instance == null) {
			throw new ContextError("Factory " + method + " returned null");
		}
		return instance; 
	}
	
	
}
