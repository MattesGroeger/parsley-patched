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
 
package org.spicefactory.parsley.context.tree.namespaces {
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.ObjectFactoryTemplateConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.ObjectProcessorTemplateConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateParserContext;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * The configuration for a single custom configuration namespace.
 * Includes all object factories and object processors for this namespace, both
 * programmatic and template based.
 * 
 * @author Jens Halm
 */
public class NamespaceConfig 
		extends AbstractElementConfig {
	
	
	private var _objectFactoryConfigBuilders:Object;
	private var _objectProcessorConfigBuilders:Object;
	private var _uri:String;
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * Creates a new instance.
	 */
	function NamespaceConfig () {
		_objectFactoryConfigBuilders = new Object();
		_objectProcessorConfigBuilders = new Object();
	}
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("factory-config", ObjectFactoryTagConfig, [], 0);
			ep.addChildNode("factory-template", ObjectFactoryTemplateConfig, [], 0);
			ep.addChildNode("processor-config", ObjectProcessorTagConfig, [], 0);
			ep.addChildNode("processor-template", ObjectProcessorTemplateConfig, [], 0);
			ep.addAttribute("uri", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function parse (node:XML, context:ApplicationContext) : void {
		TemplateParserContext.createNewContext(this);
		try {
			super.parse(node, context);
			validateTemplates();
		} finally {
			TemplateParserContext.clearContext();
		}
	}
	
	private function validateTemplates () : void {
		for each (var processorBuilder : Object in _objectProcessorConfigBuilders) {
			if (processorBuilder is ObjectProcessorTemplateConfig) {
				var processorTemplateConfig:ObjectProcessorTemplateConfig = ObjectProcessorTemplateConfig(processorBuilder);
				if (processorTemplateConfig.requiresFactoryTemplate) {
					var tagName:String = processorTemplateConfig.tagName;
					var factoryBuilder:Object = _objectFactoryConfigBuilders[tagName];
					if (factoryBuilder == null || !(factoryBuilder is ObjectFactoryTemplateConfig)) {
						throw new ConfigurationError("<apply-factory-template> was used in a <processor-template> without matching <factory-template>");
					}
					var factoryTemplateConfig:ObjectFactoryTemplateConfig = ObjectFactoryTemplateConfig(factoryBuilder);
					var FactoryChildConfig:Class = factoryTemplateConfig.RequiredChildConfig;
					if (FactoryChildConfig != null) {
						var ProcessorChildConfig:Class = processorTemplateConfig.RequiredChildConfig;
						if (ProcessorChildConfig == null) {
							processorTemplateConfig.RequiredChildConfig = FactoryChildConfig;
						} else if (ProcessorChildConfig != FactoryChildConfig) {
							throw new ConfigurationError("Templates for tag '" + processorTemplateConfig.tagName 
								+ "': <processor-template> and <factory-template> use different <apply-children> types");
						}
					}
				}
			} 
		}
	}
	
	
	public function set uri (value:String) : void {
		_uri = value;
	}
	/**
	 * The URI of this custom configuration namespace.
	 */
	public function get uri () : String {
		if (_uri != null) {
			return _uri;
		} else {
			return getAttributeValue("uri");
		}
	}
	
	/**
	 * Adds a custom factory configuration builder.
	 * 
	 * @param fc the custom factory configuration builder to add
	 */
	public function addFactoryConfigConfig (fc:ObjectFactoryConfigBuilder) : void {
		if (_objectFactoryConfigBuilders[fc.tagName] != undefined) {
			throw new ConfigurationError("Duplicate entry for tag " + fc.tagName + " in Namespace " + uri);
		}
		_objectFactoryConfigBuilders[fc.tagName] = fc;
	}

	/**
	 * Adds a factory template.
	 * 
	 * @param fc the factory template to add
	 */	
	public function addFactoryTemplateConfig (fc:ObjectFactoryConfigBuilder) : void {
		if (_objectFactoryConfigBuilders[fc.tagName] != undefined) {
			throw new ConfigurationError("Duplicate entry for tag " + fc.tagName + " in Namespace " + uri);
		}
		_objectFactoryConfigBuilders[fc.tagName] = fc;
	}

	/**
	 * Adds a custom processor configuration builder.
	 * 
	 * @param fc the custom processor configuration builder to add
	 */	
	public function addProcessorConfigConfig (pc:ObjectProcessorConfigBuilder) : void {
		if (_objectProcessorConfigBuilders[pc.tagName] != undefined) {
			throw new ConfigurationError("Duplicate entry for tag " + pc.tagName + " in Namespace " + uri);
		}
		_objectProcessorConfigBuilders[pc.tagName] = pc;
	}
	
	/**
	 * Adds a processor template.
	 * 
	 * @param fc the processor template to add
	 */	
	public function addProcessorTemplateConfig (pc:ObjectProcessorConfigBuilder) : void {
		if (_objectProcessorConfigBuilders[pc.tagName] != undefined) {
			throw new ConfigurationError("Duplicate entry for tag " + pc.tagName + " in Namespace " + uri);
		}
		_objectProcessorConfigBuilders[pc.tagName] = pc;
	}
	
	/**
	 * Returns the <code>RootObjectFactoryConfig</code> instance for the specified tag name.
	 * 
	 * @param tagName the name of the custom tag
	 * @return the <code>RootObjectFactoryConfig</code> instance for the specified tag name
	 * @throws org.spicefactory.parsley.context.ConfigurationError if no object factory exists for
	 * the specified tag name
	 */
	public function getRootObjectFactoryConfig (tagName:String) : RootObjectFactoryConfig {
		var builder:ObjectFactoryConfigBuilder = ObjectFactoryConfigBuilder(_objectFactoryConfigBuilders[tagName]);
		if (builder == null) {
			throw new ConfigurationError("No ObjectFactoryConfig specified for tag '" + tagName + "'");
		}
		return builder.buildRootObjectFactoryConfig();
	}

	/**
	 * Returns the <code>NestedObjectFactoryConfig</code> instance for the specified tag name.
	 * 
	 * @param tagName the name of the custom tag
	 * @return the <code>NestedObjectFactoryConfig</code> instance for the specified tag name
	 * @throws org.spicefactory.parsley.context.ConfigurationError if no object factory exists for
	 * the specified tag name
	 */	
	public function getNestedObjectFactoryConfig (tagName:String) : NestedObjectFactoryConfig {
		var builder:ObjectFactoryConfigBuilder = ObjectFactoryConfigBuilder(_objectFactoryConfigBuilders[tagName]);
		if (builder == null) {
			throw new ConfigurationError("No ObjectFactoryConfig specified for tag '" + tagName + "'");
		}
		return builder.buildNestedObjectFactoryConfig();
	}

	/**
	 * Returns the <code>ObjectProcessorConfig</code> instance for the specified tag name.
	 * 
	 * @param tagName the name of the custom tag
	 * @return the <code>ObjectProcessorConfig</code> instance for the specified tag name
	 * @throws org.spicefactory.parsley.context.ConfigurationError if no object processor exists for
	 * the specified tag name
	 */	
	public function getObjectProcessorConfig (tagName:String) : ObjectProcessorConfig {
		var builder:ObjectProcessorConfigBuilder = ObjectProcessorConfigBuilder(_objectProcessorConfigBuilders[tagName]);
		if (builder == null) {
			throw new ConfigurationError("No ObjectProcessorConfig specified for tag '" + tagName + "'");
		}
		return builder.buildObjectProcessorConfig();
	}



}

}