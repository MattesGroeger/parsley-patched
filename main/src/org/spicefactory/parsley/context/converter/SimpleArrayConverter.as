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
 
package org.spicefactory.parsley.context.converter {
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.parsley.context.ConfigurationError;

/**
 * Converter implementation that converts comma-separated strings to Arrays.
 * 
 * @author Jens Halm
 */
public class SimpleArrayConverter implements Converter {
	
	
	private var _elementConverter:Converter;
	private var _delimiter:String;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param conv the Converter instance to use for element conversion
	 */
	public function SimpleArrayConverter (conv:Converter) {
		_elementConverter = conv;
		_delimiter = ",";
	}
	
	/**
	 * The delimiter to use for splitting the Array.
	 */
	public function get delimiter () : String {
		return _delimiter;
	}
	public function set delimiter (delimiter:String) : void {
		_delimiter = delimiter;
	}
	
	/**
	 * @inheritDoc
	 */
	public function convert (value:*) : * {
		if (value is Array) {
			return value;
		}
		if (value == null) {
			throw new ConfigurationError("Cannot convert null value to Array"); 
		}
		var strings:Array = value.toString().split(_delimiter);
		var converted:Array = new Array();
		for each (var s:String in strings) {
			converted.push(_elementConverter.convert(s));
		}
		return converted;
	}
	
	
}

}