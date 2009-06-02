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

package org.spicefactory.parsley.core.builder {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.metadata.InternalProperty;
import org.spicefactory.parsley.core.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.factory.FactoryObjectInstantiator;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.ObjectInstantiator;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;

import flash.utils.getQualifiedClassName;

/**
 * ObjectDefinitionBuilder implementation that processes ActionScript configuration classes.
 * 
 * @author Jens Halm
 */
public class ActionScriptObjectDefinitionBuilder implements ObjectDefinitionBuilder {

	
	private static const log:Logger = LogContext.getLogger(ActionScriptObjectDefinitionBuilder);

	
	private var configClasses:Array;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param configClasses the classes that contain the ActionScript configuration
	 */
	function ActionScriptObjectDefinitionBuilder (configClasses:Array) {
		this.configClasses = configClasses;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function build (registry:ObjectDefinitionRegistry) : void {
		var containerErrors:Array = new Array();
		for each (var configClass:Class in configClasses) {
			try {
				var ci:ClassInfo = ClassInfo.forClass(configClass, registry.domain);
				var configInstance:Object = new configClass();
				var factoryErrors:Array = new Array();
				for each (var property:Property in ci.getProperties()) {
					try {
						var internalMeta:Array = property.getMetadata(InternalProperty);
						if (internalMeta.length == 0 && property.readable) {
							buildTargetDefinition(property, configInstance, registry);
						} 
					}
					catch (e:Error) {
						var msg:String = "Error building object definition for " + property;
						log.error(msg + "{0}", e);
						factoryErrors.push(msg + ": " + e.message);						
					}
				}
				if (factoryErrors.length > 0) {
					containerErrors.push("One or more errors processing " + getQualifiedClassName(configInstance) 
							+ ":\n " + factoryErrors.join("\n "));
				}
			}
			catch (e:Error) {
				var message:String = "Error processing " + getQualifiedClassName(configInstance);
				log.error(message + "{0}", e);
				containerErrors.push(message + ":\n " + e.message);
			}
		}
		if (containerErrors.length > 0) {
			throw new ContextError("One or more errors in ActionScriptObjectDefinitionBuilder:\n " 
					+ containerErrors.join("\n "));	
		}
	}
	
	private function buildTargetDefinition (configClassProperty:Property, configClass:Object, registry:ObjectDefinitionRegistry) : void {
		var factory:ObjectDefinitionFactory;
		if (configClassProperty.type.isType(ObjectDefinitionFactory)) {
			factory = configClassProperty.getValue(configClass);
		}
		else {
			var definitionMetaArray:Array = configClassProperty.getMetadata(ObjectDefinitionMetadata);
			var definitionMeta:ObjectDefinitionMetadata = (definitionMetaArray.length > 0) ? 
					ObjectDefinitionMetadata(definitionMetaArray[0]) : null;
			var id:String = (definitionMeta != null && definitionMeta.id != null) ? definitionMeta.id : configClassProperty.name;
			var lazy:Boolean = (definitionMeta != null) ? definitionMeta.lazy : false;
			var singleton:Boolean = (definitionMeta != null) ? definitionMeta.singleton : true;
			factory = new DefaultObjectDefinitionFactory(configClassProperty.type.getClass(), id, lazy, singleton);
		}
		var definition:RootObjectDefinition = factory.createRootDefinition(registry);
		registry.registerDefinition(definition);
		if (!configClassProperty.type.isType(ObjectDefinitionFactory)) {
			var inst:ObjectInstantiator = new ConfingClassPropertyInstantiator(configClass, configClassProperty);
			if (definition.instantiator is FactoryObjectInstantiator) {
				FactoryObjectInstantiator(definition.instantiator).factoryDefinition.instantiator = inst;
			}
			else {
				definition.instantiator = inst;
			} 
		}
	}
}
}

import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.ObjectInstantiator;

class ConfingClassPropertyInstantiator implements ObjectInstantiator {

	private var configClass:Object;
	private var property:Property;

	function ConfingClassPropertyInstantiator (configClass:Object, property:Property) {
		this.configClass = configClass;
		this.property = property;
	}
	
	public function instantiate (context:Context) : Object {
		return property.getValue(configClass);
	}
	
}

