/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.tree.namespaces.template.client {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.FactoryMetadataConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateProcessorContext;

/**
 * Represents a client node of a template used in the context of an root object configuration.
 * 
 * @author Jens Halm
 */
public class RootFactoryTemplateClientConfig  
		extends AbstractFactoryTemplateClientConfig implements RootObjectFactoryConfig {
	
	
	private var _factoryMetadataConfig:FactoryMetadataConfig;
	
	private var _instance:Object;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param ofc the object factory for this template client
	 * @param fm the metadata for the factory template
	 * @param childProcessor the optional element configuration for child nodes
	 */
	function RootFactoryTemplateClientConfig (
			ofc:ObjectFactoryConfig, fm:FactoryMetadataConfig, childProcessor:ElementConfig) {
		super(ofc, childProcessor);
		_factoryMetadataConfig = fm;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		TemplateProcessorContext.pushTemplateContext(applicationContext, childProcessor, attributes);
		var value:String = _factoryMetadataConfig.id;
		TemplateProcessorContext.popTemplateContext();
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return objectFactoryConfig.type;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get singleton () : Boolean {
		TemplateProcessorContext.pushTemplateContext(applicationContext, childProcessor, attributes);
		var value:Boolean = _factoryMetadataConfig.singleton;
		TemplateProcessorContext.popTemplateContext();
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lazy () : Boolean {
		TemplateProcessorContext.pushTemplateContext(applicationContext, childProcessor, attributes);
		var value:Boolean = _factoryMetadataConfig.lazy;
		TemplateProcessorContext.popTemplateContext();
		return value;
	}

	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {
		// return existing instance if possible
		if (singleton && _instance != null) {
			return _instance;
		}
		
		TemplateProcessorContext.pushTemplateContext(applicationContext, childProcessor, attributes);
		var obj:Object = objectFactoryConfig.createObject();
		TemplateProcessorContext.popTemplateContext();
		
		// save instance if necessary	
		if (singleton) {
			_instance = obj;
		}
		
		return obj;
	}


}

}