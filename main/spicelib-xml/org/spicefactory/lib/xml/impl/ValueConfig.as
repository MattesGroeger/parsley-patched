/*
 * Copyright 2009 the original author or authors.
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
 
package org.spicefactory.lib.xml.impl {
import org.spicefactory.lib.reflect.Property;

/**
 * Configuration for a single value mapping to an XML attribute or text node.
 * 
 * @author Jens Halm
 */
public class ValueConfig {
	
	
	private var _xmlName:QName;
	private var _property:Property;
	private var _required:Boolean;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param attributeName the local name of the attribute
	 * @param property the property the attribute value should be applied to
	 * @param required whether this attribute is required
	 */
	public function ValueConfig (xmlName:QName, property:Property, required:Boolean = true) {
		_xmlName = xmlName;
		_property = property;
		_required = required;
	}
	
	/**
	 * The local name of the attribute.
	 */
	public function get xmlName () : QName {
		return _xmlName;
	}
	
	/**
	 * The Property the attribute should map to.
	 */
	public function get property () : Property {
		return _property;
	}
	
	/**
	 * Indicates whether this attribute is required.
	 */
	public function get required () : Boolean {
		return _required;
	}
	

}

}