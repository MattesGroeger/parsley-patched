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
 
package org.spicefactory.parsley.context.tree.core {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractValueHolderConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.tree.Attribute;
import org.spicefactory.parsley.context.tree.values.BoundValueConfig;
import org.spicefactory.parsley.context.tree.values.MessageBindingConfig;
import org.spicefactory.parsley.context.tree.values.ReferenceConfig;
import org.spicefactory.parsley.context.tree.values.SimpleValueConfig;
import org.spicefactory.parsley.context.tree.values.ValueConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the configuration for setting the value of a single property
 * - in XML configuration the <code>&lt;property&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class PropertyConfig	 
		extends AbstractValueHolderConfig implements ObjectProcessorConfig, ApplicationContextAware {


	private var _name:String;
	private var _valueConfig:ValueConfig;
	private var _context:ApplicationContext;
	private var _isStatic:Boolean = false;
	
	
	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0, 1);
			addValueConfigs(ep);
			ep.addChildNode("message-binding", MessageBindingConfig, [], 0);
			ep.addAttribute("name", StringConverter.INSTANCE, true);
			ep.addAttribute("value", null, false);
			ep.addAttribute("ref", StringConverter.INSTANCE, false);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
		
	
	/**
	 * Creates a new instance.
	 */
	function PropertyConfig () {
		
	}
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	/**
	 * @private
	 */
	public function addChildConfig (config:ValueConfig) : void {
		throw new ConfigurationError("addChildConfig is not supported in PropertyConfig");
	}
	
	public function set name (name:String) : void {
		_name = name;
	}
	
	
	public function set isStatic (value:Boolean) : void {
		_isStatic = value;
	}
	
	public function get isStatic () : Boolean {
		return _isStatic;
	}
	
	
	/**
	 * The name of the propery.
	 */
	public function get name () : String {
		if (_name != null) {
			return _name;
		} else {
			return getAttributeValue("name");
		}
	}
	
	/**
	 * @private
	 */
	public override function setAttribute (name:String, attribute:Attribute) : void {
		if (name == "value") {
			setValueAttribute(attribute);
		} else if (name == "ref") {
			setRefAttribute(attribute);
		} else {
			super.setAttribute(name, attribute);
		}
	}
	
	/**
	 * Sets a simple value for this property configuration.
	 * 
	 * @param attr the attribute specifying the value for this property
	 */
	public function setValueAttribute (attr:Attribute) : void {
		checkState();
		var simpleValue:SimpleValueConfig = new SimpleValueConfig();
		simpleValue.setAttribute("value", attr);
		_valueConfig = simpleValue;
	}
	
	/**
	 * Sets a reference to another object in the <code>ApplicationContext</code> as the
	 * value for this property configuration.
	 * 
	 * @param attr the attribute specifying the name of the referenced object 
	 */
	public function setRefAttribute (attr:Attribute) : void {
		checkState();
		var ref:ReferenceConfig = new ReferenceConfig();
		ref.applicationContext = _context;
		ref.setAttribute("id", attr);
		_valueConfig = ref;
	}
	
	/**
	 * The value for this property configuration specified as a nested child tag.
	 */
	public function set childConfig (config:ValueConfig) : void {
		checkState();
		_valueConfig = config;
	}
	
	private function checkState () : void {
		if (_valueConfig != null) {
			throw new ConfigurationError("Only one of child text node or value or ref attributes can be specified for <property> tags");
		}	
	}
	
	/**
	 * Processes this configuration, setting the value of the property on the specified instance.
	 * 
	 * @param obj the target instance to set the property value for
	 * @param ci the type information for the target instance
	 * @param destroyCommands the chain to add commands to that need to be processed when
	 * the ApplicationContext gets destroyed
	 */
	public function process (obj:Object, ci:ClassInfo, destroyCommands:CommandChain) : void {
		if (_valueConfig == null) {
			throw new ConfigurationError("Either a child text node or value or ref attributes must be specified for <property> tags");
		}
		
		if (_valueConfig is BoundValueConfig) {
			var com:Command = BoundValueConfig(_valueConfig).bind(obj, name);
			destroyCommands.addCommand(com);
		} else {
			var propValue:* = _valueConfig.value;
			var prop:Property = (isStatic) ? ci.getStaticProperty(name) : ci.getProperty(name);
			if (prop == null) {
				throw new ConfigurationError("Class " + ci.name 
					+ " does not have a property with name " + name);
			}
			if (isStatic) {
				prop.setValue(null, propValue);
			} else {
				prop.setValue(obj, propValue);
			}
			// TODO - 1.1.0 - how to handle dynamic objects?
		}
	}
	
	
	
}

}