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
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateParserContext;

/**
 * Abstract base implementation of the <code>TemplateConfig</code> interface.
 * 
 * @author Jens Halm
 */
public class AbstractTemplateConfig	 
		extends AbstractElementConfig implements TemplateConfig {
	
	
	private var _tagName:String;
	private var _RequiredChildConfig:Class;


	/**
	 * @inheritDoc
	 */
	public override function parse (node:XML, context:ApplicationContext) : void {
		var parserContext : TemplateParserContext = TemplateParserContext.getCurrentContext();
		if (parserContext == null) {
			throw new ConfigurationError("No active TemplateParserContext available - misplaced template tag");
		}
		parserContext.templateConfig = this;
		super.parse(node, context);
		parserContext.templateConfig = null;
	}
	
	public function set RequiredChildConfig (Config : Class) : void {
		if (_RequiredChildConfig == null) {
			_RequiredChildConfig = Config;
		} else if (_RequiredChildConfig != Config) {
			throw new ConfigurationError("Cannot use factory-style and processor-style <apply-children> tags in the same template");
		}
	}

	/**
	 * @inheritDoc
	 */	
	public function get RequiredChildConfig () : Class {
		return _RequiredChildConfig;
	}
		
	/**
	 * @inheritDoc
	 */
	public function get tagName () : String {
		if (_tagName != null) {
			return _tagName;
		} else {
			return getAttributeValue("tagName");
		}
	}
	
	public function set tagName (value:String) : void {
		_tagName = value;
	}
	
	
	
}

}