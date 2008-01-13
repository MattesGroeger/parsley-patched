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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;	

/**
 * Abstract base class for <code>PropertyResolverConfig</code> and <code>VariableResolverConfig</code>.
 */
public class AbstractResolverConfig extends AbstractElementConfig {
	

	private var _type:ClassInfo;

	
	/**
	 * @private
	 */
	protected function createElementProcessor (requiredType:Class) : ElementProcessor {
		var ep:DefaultElementProcessor = new DefaultElementProcessor();
		ep.addAttribute("type", new ClassInfoConverter(ClassInfo.forClass(requiredType)), true);
		return ep;
	}
	
	
	public function set type (value:ClassInfo) : void {
		_type = value;
	}
	
	/**
	 * The class that implements one of the resolver interfaces.
	 */
	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
	

	
}

}