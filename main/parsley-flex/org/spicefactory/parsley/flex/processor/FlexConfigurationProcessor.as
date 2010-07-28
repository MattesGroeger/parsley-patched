/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.flex.processor {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.util.ClassUtil;
import org.spicefactory.parsley.asconfig.processor.ActionScriptConfigurationProcessor;
import org.spicefactory.parsley.config.Configuration;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.core.errors.ConfigurationUnitError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.tag.RootConfigurationTag;
import org.spicefactory.parsley.tag.core.MxmlObjectsTag;

/**
 * ConfigurationProcessor implementation that processes MXML configuration classes.
 * 
 * @author Jens Halm
 */
public class FlexConfigurationProcessor extends ActionScriptConfigurationProcessor {
	
	
	private static const log:Logger = LogContext.getLogger(FlexConfigurationProcessor);
	
	
	private var configClasses:Array;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param configClasses the classes that contain the MXML configuration
	 */
	function FlexConfigurationProcessor (configClasses:Array) {
		super(configClasses);
		this.configClasses = configClasses;
	}
	
	
	/**
	 * @private
	 */
	protected override function processClass (configClass:Class, config:Configuration) : void {
		var ci:ClassInfo = ClassInfo.forClass(configClass, config.domain);
		if (ci.isType(MxmlObjectsTag)) {
			
			var root:MxmlObjectsTag = new configClass();
			root.init(config.registry.properties);
			
			var errors:Array = new Array();
			for each (var obj:Object in root.objects) {
				try {
					processObject(obj, config);
				} 
				catch (e:Error) {
					errors.push(e);		
				}
			}
			if (errors.length > 0) {
				throw new ConfigurationUnitError(configClass, errors);
			}
		}
		else {
			super.processClass(configClass, config);
		}
	}
	
	// TODO - copied from XmlConfigurationProcessor
	private function processObject (obj:Object, config:Configuration) : void {
		try {
			if (obj is ObjectDefinitionFactory) {
				handleLegacyFactory(ObjectDefinitionFactory(obj), config.registry);
			}
			else if (obj is RootConfigurationElement) {
				RootConfigurationElement(obj).process(config);
			}
			else if (obj is RootConfigurationTag) {
				/* TODO - RootConfigurationTag is deprecated - remove in later versions */
				RootConfigurationTag(obj).process(config.registry);
			}
			else {
				createDefinition(obj, config);
			}
		}
		catch (e:Error) {
			log.error("Error processing {0}: {1}", obj, e);
			throw new ConfigurationUnitError(obj, [e]);
		}
	}
	
	// TODO - copied from XmlConfigurationProcessor
	private function createDefinition (obj:Object, config:Configuration) : void {
		var idProp:Property = ClassInfo.forInstance(obj, config.domain).getProperty("id");
				
		config.builders
			.forInstance(obj)
				.asSingleton()
					.id((idProp == null) ? null : idProp.getValue(obj))
					.register();
	}
	
	private function handleLegacyFactory (factory:ObjectDefinitionFactory, registry:ObjectDefinitionRegistry) : void {
		/* TODO - ObjectDefinitionFactory is deprecated - remove in later versions */
		var definition:ObjectDefinition = factory.createRootDefinition(registry);
		registry.registerDefinition(definition);
	}
	
	
	/**
	 * @private
	 */
	public override function toString () : String {
		var classNames:Array = new Array();
		for each (var type:Class in configClasses) {
			classNames.push(ClassUtil.getSimpleName(type));
		}
		return "FlexConfig{" + classNames.join(",") + "}";
	}
	
	
}
}
