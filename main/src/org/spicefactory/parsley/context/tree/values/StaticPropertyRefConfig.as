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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a reference to a static property - in XML configuration the 
 * <code>&lt;static-property-ref&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class StaticPropertyRefConfig  
		extends AbstractElementConfig implements ValueConfig {
	
	
	private var _type:ClassInfo;
	private var _property:String;
	
	

	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("type", new ClassInfoConverter(), true);
			ep.addAttribute("property", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	

	/**
	 * Creates a new instance.
	 */
	function StaticPropertyRefConfig () {
		
	}
	
	/**
	 * The class where the static property is declared.
	 */
	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
	
	public function set type (value:ClassInfo) : void {
		_type = value;
	}
	
	/**
	 * The name of the property.
	 */
	public function get property () : String {
		if (_property != null) {
			return _property;
		} else {
			return getAttributeValue("property");
		}
	}
	
	public function set property (property:String) : void {
		_property = property;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		var prop:Property = type.getStaticProperty(property);
		if (prop == null) {
			throw new ConfigurationError("Class " + type.name 
				+ " does not have a static property with name " + property);
		}
		return prop.getValue(null);
	}		
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "Static Property '" + type.name + "." + property + "'";
	}
	
	
}

}