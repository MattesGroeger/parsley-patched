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
import org.spicefactory.parsley.context.converter.SimpleArrayConverter;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents an array whose elements are specified by comma-separated string values 
 * - in XML configuration the &lt;string-array&gt; or &lt;number-array&gt; tag. 
 * 
 * @author Jens Halm
 */
public class SimpleArrayConfig extends SimpleValueConfig {
	
	
	private var _delimiter:String;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("delimiter", StringConverter.INSTANCE, false, ",");
			ep.addTextNode("value", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * Creates a new instance.
	 * 
	 * @param conv the Converter to use to convert the comma-separated values into an Array
	 */
	function SimpleArrayConfig (conv:SimpleArrayConverter) {
		super(conv);
	}
	
	public function set delimiter (value:String) : void {
		_delimiter = value;
	}
	
	/**
	 * The delimiter for the element values (default is <code>','</code>).
	 */
	public function get delimiter () : String {
		if (_delimiter != null) {
			return _delimiter;
		} else {
			return getAttributeValue("delimiter");
		}		
	}
	
	/**
	 * @inheritDoc
	 */
	public override function get value () : * {
		SimpleArrayConverter(converter).delimiter = delimiter;
		return super.value;
	}
	
	
	
}

}