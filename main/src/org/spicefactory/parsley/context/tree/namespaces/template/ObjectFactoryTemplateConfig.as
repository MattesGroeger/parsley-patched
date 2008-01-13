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
 
package org.spicefactory.parsley.context.tree.namespaces.template {
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.ObjectFactoryConfigBuilder;
import org.spicefactory.parsley.context.tree.namespaces.template.client.NestedFactoryTemplateClientConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.client.RootFactoryTemplateClientConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the template for an object factory - in XML configuration
 * the <code>&lt;factory-template&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class ObjectFactoryTemplateConfig  
		extends AbstractTemplateConfig implements ObjectFactoryConfigBuilder {
	
	
	private var _factoryMetadataConfig:FactoryMetadataConfig;
	private var _objectFactoryConfigWrapper:ObjectFactoryConfigWrapper;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("tag-name", StringConverter.INSTANCE, true);
			ep.addChildNode("factory-metadata", FactoryMetadataConfig, [], 1, 1);
			ep.addChildNode("object", ObjectFactoryConfigWrapper, [], 1, 1);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	
	
	/**
	 * The configuration for factory metadata.
	 */
	public function set factoryMetadataConfig (value:FactoryMetadataConfig) : void {
		_factoryMetadataConfig = value;
	}
	
	/**
	 * The actual template for the object factory.
	 */
	public function set objectConfig (value:ObjectFactoryConfigWrapper) : void {
		_objectFactoryConfigWrapper = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function buildRootObjectFactoryConfig() : RootObjectFactoryConfig {
		var ChildConfigClass:Class = RequiredChildConfig;
		var childProcessor:ElementConfig = (ChildConfigClass != null) ? new ChildConfigClass() : null;
		// TODO - 1.1.0 - check behaviour if template client tags have children in case of ChildConfigClass == null
		return new RootFactoryTemplateClientConfig (
			_objectFactoryConfigWrapper.getObjectFactoryConfig(), 
			_factoryMetadataConfig, 
			childProcessor
		);
	}

	/**
	 * @inheritDoc
	 */
	public function buildNestedObjectFactoryConfig() : NestedObjectFactoryConfig {
		var ChildConfigClass:Class = RequiredChildConfig;
		var config : ElementConfig = (ChildConfigClass == null) ? null : new ChildConfigClass();
		return new NestedFactoryTemplateClientConfig (
			_objectFactoryConfigWrapper.getObjectFactoryConfig(), config);
	}


}

}