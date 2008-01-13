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
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a value with an explicitly specified Converter - in XML configuration
 * the &lt;custom&gt; tag.
 * 
 * @author Jens Halm
 */
public class CustomValueConfig 
		extends AbstractElementConfig implements ValueConfig, ApplicationContextAware {
	
	
	private var _context:ApplicationContext;
	
	private var _converter:String;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("converter", StringConverter.INSTANCE, true);
			ep.addTextNode("stringValue", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
		
	
	/**
	 * Creates a new instance.
	 */
	function CustomValueConfig () {
		
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
	
	public function set converter (convId:String) : void {
		_converter = convId;
	}
	
	/**
	 * The name of the Converter instance in the ApplicationContext
	 * that should be used for type conversion.
	 */
	public function get converter () : String {
		if (_converter != null) {
			return _converter;
		} else {
			return getAttributeValue("converter");
		}
	}
	
	/**
	 * The original string value before conversion.
	 */
	public function get stringValue () : * {
		return getAttribute("stringValue").getValue(); // do not cache
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		var obj:Object = _context.getObject(converter);
		if (obj == null) {
			throw new ConfigurationError("No converter registered with id '" + converter + "'");
		} else if (!(obj is Converter)) {
			throw new ConfigurationError("Object with id '" + converter + "' does not implement Converter");
		}
		return Converter(obj).convert(stringValue);
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "Custom Value '" + stringValue + "'";
	}
	
	
	
}

}