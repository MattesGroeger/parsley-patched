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
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.core.ListenerConfig;
import org.spicefactory.parsley.context.tree.core.MethodInvocationConfig;
import org.spicefactory.parsley.context.tree.core.PropertyConfig;
import org.spicefactory.parsley.context.tree.namespaces.ObjectProcessorConfigBuilder;
import org.spicefactory.parsley.context.tree.namespaces.template.client.CompositeObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.client.ProcessorTemplateClientConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the template for an object processor - in XML configuration
 * the <code>&lt;processor-template&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class ObjectProcessorTemplateConfig  
		extends AbstractTemplateConfig implements ObjectProcessorConfigBuilder {
	
	
	private var _requiresFactoryTemplate:Boolean;
	
	private var _processorConfig:CompositeObjectProcessorConfig;



	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("tag-name", StringConverter.INSTANCE, true);
			ep.addChildNode("property", PropertyConfig, [], 0);
			ep.addChildNode("init-method", MethodInvocationConfig, [], 0);
			ep.addChildNode("listener", ListenerConfig, [], 0);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}


	/**
	 * Creates a new instance.
	 */
	function ObjectProcessorTemplateConfig () {
		_processorConfig = new CompositeObjectProcessorConfig();
	}

	/**
	 * Adds the configuration for a property to this template.
	 * 
	 * @param config the configuration for a property to add to this template
	 */
	public function addPropertyConfig (config:PropertyConfig) : void {
		_processorConfig.addPropertyConfig(config);
	}
	
	/**
	 * Adds the configuration for a method invocation to this template.
	 * 
	 * @param config the configuration for a method invocation to add to this template
	 */
	public function addInitMethodConfig (config:MethodInvocationConfig) : void {
		_processorConfig.addInitMethodConfig(config);
	}

	/**
	 * Adds the configuration for a listener registration to this template.
	 * 
	 * @param config the configuration for a listener registration to add to this template
	 */		
	public function addListenerConfig (config:ListenerConfig) : void {
		_processorConfig.addListenerConfig(config);
	}
	
	/**
	 * Indicates whether a matching factory template for the same tag name is required.
	 * This is the case when the <code>&lt;apply-factory-template&gt;</code> tag is used
	 * within a processor template.
	 */
	public function get requiresFactoryTemplate () : Boolean {
		return _requiresFactoryTemplate;
	}
	
	public function set requiresFactoryTemplate (value:Boolean) : void {
		_requiresFactoryTemplate = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function buildObjectProcessorConfig () : ObjectProcessorConfig {
		var ChildConfigClass:Class = RequiredChildConfig;
		var config : ElementConfig = (ChildConfigClass == null) ? null : new ChildConfigClass();
		return new ProcessorTemplateClientConfig(_processorConfig, config);
	}


}

}