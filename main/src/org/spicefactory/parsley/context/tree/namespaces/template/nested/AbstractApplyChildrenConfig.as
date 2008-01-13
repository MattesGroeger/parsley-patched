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
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.TemplateConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateParserContext;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Abstract base implementation for configuration objects that represent
 * the <code>&lt;apply-children&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class AbstractApplyChildrenConfig extends AbstractElementConfig {
	
	
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
	 * Sets class of the (optional) child config. This class must implement <code>ElementConfig</code>.
	 * Possible values are <code>PartialValueHolderConfig</code> and 
	 * <code>CompositeObjectProcessorConfig</code>.
	 * 
	 * @param ChildConfig the class of the child configuration
	 */
	protected function setRequiredChildConfig (ChildConfig:Class) : void {
		var parserContext : TemplateParserContext = TemplateParserContext.getCurrentContext();
		if (parserContext == null) {
			throw new ConfigurationError("No active TemplateParserContext available - <apply-children> tags can only be used in templates");
		}
		var container:TemplateConfig = parserContext.templateConfig;
		if (container == null) {
			throw new ConfigurationError("No active TemplateContainer available - <apply-children> tags can only be used in templates");
		}
		container.RequiredChildConfig = ChildConfig;
	}



}

}