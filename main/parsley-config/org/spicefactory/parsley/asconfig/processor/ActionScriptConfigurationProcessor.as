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
import org.spicefactory.parsley.asconfig.metadata.DynamicObjectDefinitionMetadata;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.util.ClassUtil;
import org.spicefactory.parsley.asconfig.metadata.InternalProperty;
import org.spicefactory.parsley.asconfig.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.errors.ConfigurationProcessorError;
import org.spicefactory.parsley.core.errors.ConfigurationUnitError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.tag.ResolvableConfigurationValue;
import org.spicefactory.parsley.tag.RootConfigurationTag;

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
	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		var errors:Array = new Array();
		for each (var configClass:Class in configClasses) {
			try {
				
				processClass(configClass, registry);
				
			}
			catch (e:Error) {
				log.error("Error processing {0}: {1}", configClass, e);
				errors.push(e);
			}
		}
		if (errors.length > 0) {
			throw new ConfigurationProcessorError(this, errors);	
		}
	}
	
	private function processClass (configClass:Class, registry:ObjectDefinitionRegistry) : void {
		var ci:ClassInfo = ClassInfo.forClass(configClass, registry.domain);
		var configInstance:Object = new configClass();

		var errors:Array = new Array();
		for each (var property:Property in ci.getProperties()) {
			try {
				if (isValidRootConfig(property)) {
							
					processProperty(property, configInstance, registry);
					
				} 
			}
			catch (e:Error) {
				errors.push(e);						
			}
		}
		if (errors.length > 0) {
			throw new ConfigurationUnitError(configClass, errors);
		}
	}
	
	private function processProperty (property:Property, configClass:Object, registry:ObjectDefinitionRegistry) : void {
		try {
			if (property.type.isType(ObjectDefinitionFactory)) {
				handleLegacyFactory(property.getValue(configClass), registry);
			}
			else if (property.type.isType(RootConfigurationTag)) {
				RootConfigurationTag(property.getValue(configClass)).process(registry);
			}
			else {
				createDefinition(property, configClass, registry);
			}
		}
		catch (e:Error) {
			log.error("Error processing {0}: {1}", property, e);
			throw new ConfigurationUnitError(property, [e]);
		}
	}
	
	private function createDefinition (property:Property, configClass:Object, registry:ObjectDefinitionRegistry) : void {
		var metadata:Object = getMetadata(property);
		var id:String = (metadata.id != null) ? metadata.id : property.name;
		if (metadata is ObjectDefinitionMetadata && ObjectDefinitionMetadata(metadata).singleton) {
			var singleton:ObjectDefinitionMetadata = ObjectDefinitionMetadata(metadata);
			registry.builders
					.forSingletonDefinition(property.type.getClass())
					.id(id)
					.lazy(singleton.lazy)
					.order(singleton.order)
					.instantiator(new ConfingClassPropertyInstantiator(configClass, property))
					.buildAndRegister();
		}
		else {
			registry.builders
					.forDynamicDefinition(property.type.getClass())
					.id(id)
					.instantiator(new ConfingClassPropertyInstantiator(configClass, property))
					.buildAndRegister();
		}
	}
	
	private function handleLegacyFactory (factory:ObjectDefinitionFactory, registry:ObjectDefinitionRegistry) : void {
		/* TODO - ObjectDefinitionFactory is deprecated - remove in later versions */
		var definition:ObjectDefinition = factory.createRootDefinition(registry);
		registry.registerDefinition(definition);
	}
	
	private function isValidRootConfig (property:Property) : Boolean {
		return (property.getMetadata(InternalProperty).length == 0 
				&& property.readable 
				&& !property.type.isType(ResolvableConfigurationValue) 
				&& !property.type.isType(ObjectDefinitionDecorator));
	}
	
	private function getMetadata (property:Property) : Object {
		var dynMetadataArray:Array = property.getMetadata(DynamicObjectDefinitionMetadata);
		if (dynMetadataArray.length > 0) {
			return DynamicObjectDefinitionMetadata(dynMetadataArray[0]); 
		}
		var definitionMetaArray:Array = property.getMetadata(ObjectDefinitionMetadata);
		return (definitionMetaArray.length > 0) 
				? ObjectDefinitionMetadata(definitionMetaArray[0]) 
				: new ObjectDefinitionMetadata();
	}
	
	
	/**
	 * @private
	 */
	public function toString () : String {
		var classNames:Array = new Array();
		for each (var type:Class in configClasses) {
			classNames.push(ClassUtil.getSimpleName(type));
		}
		return "ActionScriptConfig{" + classNames.join(",") + "}";
	}
}
}

import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ContainerObjectInstantiator;

class ConfingClassPropertyInstantiator implements ContainerObjectInstantiator {

	private var configClass:Object;
	private var property:Property;

	function ConfingClassPropertyInstantiator (configClass:Object, property:Property) {
		this.configClass = configClass;
		this.property = property;
	}
	
	public function instantiate (target:ManagedObject) : Object {
		return property.getValue(configClass);
	}
	
}

