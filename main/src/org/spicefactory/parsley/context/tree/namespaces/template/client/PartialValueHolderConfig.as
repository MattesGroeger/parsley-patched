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
 
package org.spicefactory.parsley.context.tree.namespaces.template.client {
import flash.utils.Dictionary;

import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractArrayValueHolderConfig;
import org.spicefactory.parsley.context.tree.values.ValueConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Value configuration used in template client nodes that merge
 * nodes from the client with nodes from the template.
 * 
 * @author Jens Halm
 */
public class PartialValueHolderConfig  
		extends AbstractArrayValueHolderConfig implements ValueConfig {
	

	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.ignoreAttributes = true;
			addValueConfigs(ep);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	

	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		var arr:Array = getArray();
		if (arr.length != 1) {
			throw new ConfigurationError("Expected exactly one child");
		}
		return arr[0];
	}
	
	/**
	 * Fills the elements from this partial array into the specified parent Array.
	 * 
	 * @param parent the parent Array to fill with elements from this partial Array
	 */
	public function fillArray (parent:Array) : void {
		var arr:Array = getArray();
		for each (var item:* in arr) {
			parent.push(item);
		}
	}



}

}