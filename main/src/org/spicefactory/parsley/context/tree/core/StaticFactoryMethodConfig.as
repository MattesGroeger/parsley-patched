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
 
package org.spicefactory.parsley.context.tree.core {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a static factory method configuration - in XML configuration
 * the <code>&lt;static-factory-method&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class StaticFactoryMethodConfig extends FactoryMethodConfig {
	
	
	private var _Class:ClassInfo;
	
	
	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			addValueConfigs(ep);
			ep.addAttribute("type", new ClassInfoConverter(null, domain), true);
			ep.addAttribute("method", StringConverter.INSTANCE, true);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
		
	
	/**
	 * Creates a new instance.
	 */
	public function StaticFactoryMethodConfig () {
		super();
	}
	
	public function set type (config:ClassInfo) : void {
		_Class = config;
	}
	
	/**
	 * The class this static factory method is declared on.
	 */
	public function get type () : ClassInfo {
		if (_Class != null) {
			return _Class;
		} else {
			return getAttributeValue("type");
		}
	}
	
	/**
	 * @private
	 */
	protected override function getFactory () : Object {
		return type.getClass();
	}		
	
	
	
}

}