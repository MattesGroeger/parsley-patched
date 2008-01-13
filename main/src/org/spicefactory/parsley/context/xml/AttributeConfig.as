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
 
package org.spicefactory.parsley.context.xml {
import org.spicefactory.lib.reflect.Converter;

/**
 * Configuration for a single attribute.
 * 
 * @author Jens Halm
 */
public class AttributeConfig {
	
	private var _name:String;
	private var _converter:Converter;
	private var _required:Boolean;
	private var _defaultValue:*;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param name the local name of the attribute
	 * @param conv the Converter instance to use for converting the attribute value
	 * @param required whether this attribute is required
	 * @param defaultValue an optional default value for this attribute
	 */
	public function AttributeConfig (name:String, conv:Converter, 
			required:Boolean, defaultValue:* = undefined) {
		_name = name;
		_converter = conv;
		_required = required;
		_defaultValue = defaultValue;
	}
	
	/**
	 * The local name of the attribute.
	 */
	public function get name () : String {
		return _name;
	}
	
	/**
	 * The Converter instance to use for converting the attribute value.
	 */
	public function get converter () : Converter {
		return _converter;
	}
	
	/**
	 * Indicates whether this attribute is required.
	 */
	public function get required () : Boolean {
		return _required;
	}
	
	/**
	 * The default value for this attribute.
	 */
	public function get defaultValue () : * {
		return _defaultValue;
	}	
	
}

}