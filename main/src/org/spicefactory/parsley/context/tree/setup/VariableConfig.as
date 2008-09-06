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

import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.tree.AbstractValueHolderConfig;
import org.spicefactory.parsley.context.tree.values.ValueConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;variable&gt;</code> tag. Defines name and value for
 * one variable of an <code>ExpressionContext</code>.
 */
public class VariableConfig	 
		extends AbstractValueHolderConfig {
	
	
	private var _name:String;
	private var _valueConfig:ValueConfig;
	

	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(1, 1);
			addValueConfigs(ep);
			ep.addAttribute("name", StringConverter.INSTANCE, true);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	
	
	public function set name (name:String) : void {
		_name = name;
	}
	
	/**
	 * The name of the variable.
	 */
	public function get name () : String {
		if (_name != null) {
			return _name;
		} else {
			return getAttributeValue("name");
		}
	}
	
	/**
	 * The value configuration of this variable.
	 */
	public function set childConfig (config:ValueConfig) : void {
		_valueConfig = config;
	}
	
	/**
	 * The value of this variable.
	 */
	public function get value () : * {
		return _valueConfig.value;
	}
	
	
	
}

}