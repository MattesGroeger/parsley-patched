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
 
package org.spicefactory.parsley.context.tree.namespaces {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Abstract base implementation for configuration classes that use programmatic
 * configuration for custom tags.
 *  
 * @author Jens Halm
 */
public class AbstractTagConfig  
		extends AbstractElementConfig {
	
	
	
	private var _tagName:String;
	private var _type:ClassInfo;
	
	
	/**
	 * @private
	 */
	protected function createElementProcessor (requiredType:Class) : ElementProcessor {
		var ep:DefaultElementProcessor = new DefaultElementProcessor();
		ep.addAttribute("tag-name", StringConverter.INSTANCE, true);
		ep.addAttribute("type", new ClassInfoConverter(ClassInfo.forClass(requiredType), domain), true);
		return ep;
	}	
	
	/**
	 * The local name of the tag this instance is reponsible for.
	 */
	public function get tagName () : String {
		if (_tagName != null) {
			return _tagName;
		} else {
			return getAttributeValue("tagName");
		}
	}
	
	public function set tagName (param:String) : void {
		_tagName = param;
	}
	
	/**
	 * The class that is used for programmatic configuration for this tag.
	 */
	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
	
	public function set type (param:ClassInfo) : void {
		_type = param;
	}



}

}