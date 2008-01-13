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
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.client.PartialValueHolderConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateProcessorContext;
import org.spicefactory.parsley.context.tree.values.ValueConfig;

/**
 * Represents the <code>&lt;apply-children&gt;</code> tag when used in places where
 * object factory tags are located.
 * 
 * @author Jens Halm
 */
public class ApplyValueChildrenConfig  
		extends AbstractApplyChildrenConfig implements ValueConfig {
	
	
	/**
	 * @inheritDoc
	 */
	public override function parse (node : XML, context : ApplicationContext) : void {
		super.parse(node, context);
		setRequiredChildConfig(PartialValueHolderConfig);
	}

	
	private function getConfig () : PartialValueHolderConfig {
		var config:ElementConfig = TemplateProcessorContext.getActiveConfig();
		if (config == null) {
			throw new ConfigurationError("<apply-children> tags can only be used in templates");
		}
		if (!(config is PartialValueHolderConfig)) {
			throw new ConfigurationError("Internal Error: Expected instance of PartialValueHolderConfig");
		}
		return (PartialValueHolderConfig(config));		
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value  () : * {
		return getConfig().value;
	}
	
	/**
	 * Fills the elements from this partial array into the specified parent Array.
	 * 
	 * @param parent the parent Array to fill with elements from this partial Array
	 */
	public function fillArray (arr:Array) : void {
		getConfig().fillArray(arr);
	}
	
	
}

}