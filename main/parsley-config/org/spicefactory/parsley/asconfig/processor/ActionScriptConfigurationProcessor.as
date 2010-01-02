/*
 * Copyright 2009-2010 the original author or authors.
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

package org.spicefactory.parsley.asconfig.processor {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.asconfig.metadata.InternalProperty;
import org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.tag.ResolvableConfigurationValue;
import org.spicefactory.parsley.tag.RootConfigurationTag;

import flash.utils.getQualifiedClassName;

/**
 * ConfigurationProcessor implementation that processes ActionScript configuration classes.
 * May also be used for MXML configuration since those classes also compile to plain AS3 classes.
 * 
 * @author Jens Halm
 */
public class ActionScriptConfigurationProcessor implements ConfigurationProcessor {

	
	private static const log:Logger = LogContext.getLogger(ActionScriptConfigurationProcessor);

	
	private var configClasses:Array;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param configClasses the classes that contain the ActionScript configuration
	 */
	function ActionScriptConfigurationProcessor (configClasses:Array) {
		this.configClasses = configClasses;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function process (registry:ObjectDefinitionRegistry) : void {
		var errors:Array = new Array();
		for each (var configClass:Class in configClasses) {
			try {
				
				processClass(configClass, registry, errors);
				
			}
			catch (e:Error) {
				var message:String = "Error processing " + getQualifiedClassName(configClass);
				log.error(message + "{0}", e);
				errors.push(message + ":\n " + e.message);
			}
		}
		if (errors.length > 0) {
			throw new ContextError("One or more errors in ActionScriptObjectDefinitionBuilder:\n " 
					+ errors.join("\n "));	
		}
	}
	
	private function processClass (configClass:Class, registry:ObjectDefinitionRegistry, errors:Array) : void {
		var ci:ClassInfo = ClassInfo.forClass(configClass, registry.domain);
		var configInstance:Object = new configClass();
		for each (var property:Property in ci.getProperties()) {
			try {
				if (isValidRootConfig(property)) {
							
					processProperty(property, configInstance, registry);
					
				} 
			}
			catch (e:Error) {
				var msg:String = "Error building object definition for " + property;
				log.error(msg + "{0}", e);
				errors.push(msg + ": " + e.message);						
			}
		}
	}
	
	private function processProperty (property:Property, configClass:Object, registry:ObjectDefinitionRegistry) : void {
		if (property.type.isType(ObjectDefinitionFactory)) {
			/* TODO - ObjectDefinitionFactory is deprecated - remove in later versions */
			var factory:ObjectDefinitionFactory = property.getValue(configClass);
			var definition:RootObjectDefinition = factory.createRootDefinition(registry);
			registry.registerDefinition(definition);
		}
		else if (property.type.isType(RootConfigurationTag)) {
			RootConfigurationTag(property.getValue(configClass)).process(registry);
		}
		else {
			var metadata:ObjectDefinitionMetadata = getMetadata(property);
			var id:String = (metadata.id != null) ? metadata.id : property.name;
			registry.builders
					.forRootDefinition(property.type.getClass())
					.id(id)
					.lazy(metadata.lazy)
					.singleton(metadata.singleton)
					.order(metadata.order)
					.instantiator(new ConfingClassPropertyInstantiator(configClass, property))
					.buildAndRegister();
		}
	}
	
	private function isValidRootConfig (property:Property) : Boolean {
		return (property.getMetadata(InternalProperty).length == 0 
				&& property.readable 
				&& !property.type.isType(ResolvableConfigurationValue) 
				&& !property.type.isType(ObjectDefinitionDecorator));
	}
	
	private function getMetadata (property:Property) : ObjectDefinitionMetadata {
		var definitionMetaArray:Array = property.getMetadata(ObjectDefinitionMetadata);
		return (definitionMetaArray.length > 0) 
				? ObjectDefinitionMetadata(definitionMetaArray[0]) 
				: new ObjectDefinitionMetadata();
	}
}
}

import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.definition.ContainerObjectInstantiator;

class ConfingClassPropertyInstantiator implements ContainerObjectInstantiator {

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

