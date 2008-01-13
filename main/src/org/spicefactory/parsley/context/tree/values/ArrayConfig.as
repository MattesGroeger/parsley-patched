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

import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.tree.AbstractArrayValueHolderConfig;
	
/**
 * Represents an Array - in XML configuration the &lt;array&gt; tag.
 * The elements of the Array are repesented by child tags:<br/>
 * <code>
 * &lt;array&gt;
 *     &lt;string&gt;some string&lt;/string&gt; 
 *     &lt;string&gt;some other string&lt;/string&gt; 
 * &lt;/array&gt;
 * </code>
 * 
 * @author Jens Halm
 */
public class ArrayConfig  
		extends AbstractArrayValueHolderConfig implements ValueConfig {



	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			addValueConfigs(ep);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	
	/**
	 * Creates a new instance.
	 */
	function ArrayConfig () {
		super();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		return getArray();
	}
	
	
}

}