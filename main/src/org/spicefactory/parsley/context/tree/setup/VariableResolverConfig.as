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
 
package org.spicefactory.parsley.context.tree.setup {
import flash.utils.Dictionary;

import org.spicefactory.lib.expr.VariableResolver;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a <code>VariableResolver</code>  - in XML configuration the 
 * <code>&lt;variable-resolver&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class VariableResolverConfig extends AbstractResolverConfig {

	private static var _elementProcessor:Dictionary = new Dictionary();
	
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			_elementProcessor[domain] = createElementProcessor(VariableResolver);
		}
		return _elementProcessor[domain];
	}
	

	/**
	 * Creates and returns a new instance of the <code>PropertyResolver</code>
	 * configured by this instance.
	 * 
	 * @return a new PropertyResolver instance
	 */	
	public function createInstance () : VariableResolver {
		return type.newInstance([]) as VariableResolver;
	}

}

}