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
 
package org.spicefactory.parsley.context.tree.namespaces.template {
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.util.BooleanValue;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;factory-metadata&gt;</code> tag used in custom namespace templates.
 * 
 * @author Jens Halm
 */
public class FactoryMetadataConfig extends AbstractElementConfig {
	
	
	private var _id:String;
	private var _singleton:BooleanValue;
	private var _lazy:BooleanValue;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			ep.addAttribute("singleton", BooleanConverter.INSTANCE, false, true);
			ep.addAttribute("lazy", BooleanConverter.INSTANCE, false, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#id
	 */
	public function get id () : String {
		if (_id != null) {
			return _id;
		} else {
			return getAttribute("id").getValue(); // do not cache
		}
	}
	
	public function set id (param:String) : void {
		_id = param;
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#singleton
	 */
	public function get singleton () : Boolean {
		if (_singleton != null) {
			return _singleton.value;
		} else {
			return getAttribute("singleton").getValue(); // do not cache
		}
	}
	
	public function set singleton (value:Boolean) : void {
		_singleton = new BooleanValue(value);
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#lazy
	 */
	public function get lazy () : Boolean {
		if (_lazy != null) {
			return _lazy.value;
		} else {
			return getAttribute("lazy").getValue(); // do not cache
		}
	}
	
	public function set lazy (value:Boolean) : void {
		_lazy = new BooleanValue(value);
	}
	
	
	
}

}