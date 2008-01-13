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
 
package org.spicefactory.parsley.context.tree.values {
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a localized message from a message bundle - in XML configuration the 
 * <code>&lt;message&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class MessageConfig  
		extends AbstractElementConfig implements ValueConfig, ApplicationContextAware {


	private var _key:String;
	private var _bundle:String;
	private var _paramArrayConfig:ArrayConfig;
	private var _paramMethodConfig:ParamMethodConfig;
	private var _context:ApplicationContext;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("param-array", ArrayConfig, [], 0, 1);
			ep.addChildNode("param-method", ParamMethodConfig, [], 0, 1);
			ep.addAttribute("key", StringConverter.INSTANCE, true);
			ep.addAttribute("bundle", StringConverter.INSTANCE, false);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
		
	
	/**
	 * Creates a new instance.
	 */
	function MessageConfig () {
		
	}
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * The ApplicationContext instance to obtain the messages from.
	 */
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	/**
	 * The key of this message.
	 */
	public function get key () : String {
		if (_key != null) {
			return _key;
		} else {
			return getAttributeValue("key");
		}
	}
	
	public function set key (k:String) : void {
		_key = k;
	}
	
	/**
	 * The bundle of this message.
	 */
	public function get bundle () : String {
		if (_bundle != null) {
			return _bundle;
		} else {
			return getAttributeValue("bundle");
		}
	}
	
	public function set bundle (bundle:String) : void {
		_bundle = bundle;
	}
	
	public function set paramArrayConfig (config:ArrayConfig) : void {
		_paramArrayConfig = config;
	}
	
	/**
	 * An ArrayConfig instance representing values for parameters in this message.
	 */
	public function get paramArrayConfig () : ArrayConfig {
		return _paramArrayConfig;
	}
	
	public function set paramMethodConfig (config:ParamMethodConfig) : void {
		_paramMethodConfig = config;
	}
	
	/**
	 * An instance representing a method to be invoked to obtain the values for parameters
	 * in this message.
	 */
	public function get paramMethodConfig () : ParamMethodConfig {
		return _paramMethodConfig;
	}
	
	/**
	 * The resolved message.
	 */
	public function get value () : * {
		var params:Array = 
			(_paramArrayConfig != null) ? _paramArrayConfig.value as Array 
			: (_paramMethodConfig != null) ? _paramMethodConfig.createCommand().execute() as Array 
			: null;
		var msg:String = _context.getMessage(key, bundle, params);
		if (msg == null) {
			return new ConfigurationError("No message available for bundle '" + bundle + "' with key '" + key + "'");
		}
		return msg;
	}
	
	
	public function toString () : String {
		return "Message '" + value + "'";
	}
	
	
}

}