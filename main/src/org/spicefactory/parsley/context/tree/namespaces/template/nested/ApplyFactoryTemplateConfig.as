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
 
package org.spicefactory.parsley.context.tree.namespaces.template.nested {
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.NamespaceConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.ObjectProcessorTemplateConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.TemplateConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateParserContext;
import org.spicefactory.parsley.context.tree.values.ValueConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;apply-factory-template&gt;</code> tag. This tag is used
 * when a single custom tag should act as a factory and object processor at the same time.
 * 
 * @author Jens Halm
 */
public class ApplyFactoryTemplateConfig  
		extends AbstractElementConfig implements ValueConfig {
			
			
	private var _namespaceConfig:NamespaceConfig;
	private var _tagName:String;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			_elementProcessor = new DefaultElementProcessor();
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function parse(node : XML, context : ApplicationContext) : void {
		super.parse(node, context);
		var parserContext : TemplateParserContext = TemplateParserContext.getCurrentContext();
		if (parserContext == null) {
			throw new ConfigurationError("No active TemplateParserContext available - <apply-factory-template> tags can only be used in templates");
		}
		_namespaceConfig = parserContext.namespaceConfig;
		var config:TemplateConfig = parserContext.templateConfig;
		if (config == null) {
			throw new ConfigurationError("No active TemplateContainer available - <apply-factory-template> tags can only be used in templates");
		}
		_tagName = config.tagName;
		if (!(config is ObjectProcessorTemplateConfig)) {
			throw new ConfigurationError("<apply-factory-template> tags can only be used inside <processor-template> tags");
		}
		ObjectProcessorTemplateConfig(config).requiresFactoryTemplate = true;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value() : * {
		var factoryConfig:NestedObjectFactoryConfig = _namespaceConfig.getNestedObjectFactoryConfig(_tagName);
		return factoryConfig.value;
	}




}

}