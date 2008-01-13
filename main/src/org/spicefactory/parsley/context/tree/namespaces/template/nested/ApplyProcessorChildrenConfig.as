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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.client.CompositeObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateProcessorContext;

/**
 * Represents the <code>&lt;apply-children&gt;</code> tag when used in places where
 * object processor tags are located.
 * 
 * @author Jens Halm
 */
public class ApplyProcessorChildrenConfig  
		extends AbstractApplyChildrenConfig implements ObjectProcessorConfig {
	

	/**
	 * @inheritDoc
	 */
	public override function parse (node : XML, context : ApplicationContext) : void {
		super.parse(node, context);
		setRequiredChildConfig(CompositeObjectProcessorConfig);
	}
	
	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci:ClassInfo, destroyCommands : CommandChain) : void {
		var config:ElementConfig = TemplateProcessorContext.getActiveConfig();
		if (config == null) {
			throw new ConfigurationError("<apply-children> tags can only be used in templates");
		}
		if (!(config is CompositeObjectProcessorConfig)) {
			throw new ConfigurationError("Internal Error: Expected instance of CompositeObjectProcessorConfig");
		}		
		CompositeObjectProcessorConfig(config).process(obj, ci, destroyCommands);
	}



}

}