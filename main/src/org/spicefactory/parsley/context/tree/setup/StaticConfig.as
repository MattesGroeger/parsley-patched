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
 
package org.spicefactory.parsley.context.tree.setup {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.core.MethodInvocationConfig;
import org.spicefactory.parsley.context.tree.core.PropertyConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a single configuration for static properties or static method calls
 * - in XML configuration the <code>&lt;static&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class StaticConfig extends AbstractElementConfig {
	
	
	private var _type:ClassInfo;
	private var _processorConfigs:Array;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("property", PropertyConfig, [], 0);
			ep.addChildNode("init-method", MethodInvocationConfig, [], 0);
			ep.addAttribute("type", new ClassInfoConverter(), true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	

	
	/**
	 * Creates a new instance.
	 */
	function StaticConfig () {
		_processorConfigs = new Array();
	}
	
	/**
	 * The class where the static properties and methods of this configuration instance are declared.
	 */
	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
	
	public function set type (config:ClassInfo) : void {
		_type = config;
	}
	
	/**
	 * Adds a configuration for a static property.
	 * 
	 * @param config the configuration for a static property
	 */
	public function addPropertyConfig (config:PropertyConfig) : void {
		config.isStatic = true;
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds a configuration for a static method call.
	 * 
	 * @param config the configuration for a static method call
	 */
	public function addInitMethodConfig (config:MethodInvocationConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Processes this configuration. This method will actually set the
	 * static properties and invoke the static methods configured by this instance.
	 */
	public function process (destroyCommands:CommandChain) : void {
		for each (var processor:ObjectProcessorConfig in _processorConfigs) {
			processor.process(type.getClass(), type, destroyCommands);
		}
	}
	
	
	
}

}