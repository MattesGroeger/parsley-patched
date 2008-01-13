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
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateProcessorContext;

/**
 * Represents a client node of a template used in the context of a  
 * nested object configuration.
 * 
 * @author Jens Halm
 */
public class NestedFactoryTemplateClientConfig  
		extends AbstractFactoryTemplateClientConfig implements NestedObjectFactoryConfig {
	

	/**
	 * Creates a new instance.
	 * 
	 * @param ofc the object factory for this template client
	 * @param childProcessor the optional element configuration for child nodes
	 */
	function NestedFactoryTemplateClientConfig (
			ofc:ObjectFactoryConfig, childProcessor:ElementConfig) {
		super(ofc, childProcessor);
	}
	
	/**
	 * @inheritDoc
	 */	
	public function get value () : * {
		if (attributes != null) {
			// If this instance was requested by an ApplyFactoryTemplateConfig instance
			// the parse method of this instance was never called.
			// Any <apply-children/> tags nested in this factory template will use the context 
			// of the parent ProcessorTemplateClientConfig instance
			TemplateProcessorContext.pushTemplateContext(applicationContext, childProcessor, attributes);
		}
		var obj:Object = objectFactoryConfig.createObject();
		if (attributes != null) {
			TemplateProcessorContext.popTemplateContext();
		}
		return obj;
	}



}

}