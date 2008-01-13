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
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.core.ListenerConfig;
import org.spicefactory.parsley.context.tree.core.MethodInvocationConfig;
import org.spicefactory.parsley.context.tree.core.PropertyConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Object processor configuration used in template client nodes that merge
 * nodes from the client with nodes from the template.
 * 
 * @author Jens Halm
 */
public class CompositeObjectProcessorConfig	
		extends AbstractElementConfig implements ObjectProcessorConfig {


	private var _processorConfigs:Array;


	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.ignoreAttributes = true;
			ep.addChildNode("property", PropertyConfig, [], 0);
			ep.addChildNode("init-method", MethodInvocationConfig, [], 0);
			ep.addChildNode("listener", ListenerConfig, [], 0);
			
			ep.permitCustomNamespaces(ObjectProcessorConfig);
			
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}


	/**
	 * Creates a new instance.
	 */
	function CompositeObjectProcessorConfig () {
		_processorConfigs = new Array();
	}

	/**
	 * Adds the configuration for a property to this composite object processor.
	 * 
	 * @param config the configuration for a property to add to this composite object processor
	 */
	public function addPropertyConfig (config:PropertyConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for a method invocation to this composite object processor.
	 * 
	 * @param config the configuration for a method invocation to add to this composite object processor
	 */
	public function addInitMethodConfig (config:MethodInvocationConfig) : void {
		_processorConfigs.push(config);
	}

	/**
	 * Adds the configuration for a listener registration to this composite object processor.
	 * 
	 * @param config the configuration for a listener registration to add to this composite object processor
	 */	
	public function addListenerConfig (config:ListenerConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for a custom tag.
	 * 
	 * @param config the configuration for a custom tag.
	 */
	public function addCustomConfig (config:ObjectProcessorConfig) : void {
		_processorConfigs.push(config);
	}	

	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		for each (var processor:ObjectProcessorConfig in _processorConfigs) {
			processor.process(obj, ci, destroyCommands);
		}
	}



}

}