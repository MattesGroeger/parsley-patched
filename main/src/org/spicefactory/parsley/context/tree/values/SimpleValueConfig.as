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
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a simple value that can be represented by a single text node in XML. 
 * Examples are the <code>&lt;string&gt;</code> or <code>&lt;int&gt;</code> tags.
 * 
 * @author Jens Halm
 */
public class SimpleValueConfig  
		extends AbstractElementConfig implements ValueConfig {
	
	
	private var _converter:Converter;
	
	

	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addTextNode("value", null, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	

	/**
	 * Creates a new instance.
	 * 
	 * @param conv the converter to use for this value
	 */
	function SimpleValueConfig (conv:Converter = null) {
		_converter = conv;
	}
	
	/**
	 * The Converter to use for this value.
	 */
	protected function get converter () : Converter {
		return _converter;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		var value:* = getAttribute("value").getValue(); // do not cache
		return (_converter == null) ? value : _converter.convert(value);
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "Simple Value";
	}
	
	
}

}