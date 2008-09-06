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
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.util.collection.ArrayList;
import org.spicefactory.lib.util.collection.List;
import org.spicefactory.parsley.context.tree.AbstractArrayValueHolderConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * @private
 * This represents the ArrayList class from the temporary Spicelib collections.
 * Since they will be replaced in Spicelib 1.1.0 this class is not part of the public API.
 */
public class ListConfig  
		extends AbstractArrayValueHolderConfig implements ValueConfig {
	
	
	private var _type:ClassInfo;



	private static var _elementProcessor:Dictionary = new Dictionary();
	
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var defClass:ClassInfo = ClassInfo.forClass(ArrayList);
			var reqClass:ClassInfo = ClassInfo.forClass(List);
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.addAttribute("type", new ClassInfoConverter(reqClass, domain), false, defClass);
			addValueConfigs(ep);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	
	

	public function ListConfig () {
		super();
	}


	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
		
	public function set type (value:ClassInfo) : void {
		_type = value;
	}
	
	public function get value () : * {
		var l:List = List(type.newInstance([]));
		var arr:Array = getArray();
		for each (var item:* in arr) {
			l.append(item);
		}
		return l;
	}
	
	
	public function toString () : String {
		return "List Config";
	}
	
	
}

}