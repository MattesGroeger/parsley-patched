/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.lib.xml.mapper {
import org.spicefactory.lib.xml.XmlObjectMapper;

/**
 * @author Jens Halm
 */
public class Choice {
	
	
	private var _mappers:Array = new Array();
	
	
	public function addMapper (mapper:XmlObjectMapper) : void {
		_mappers.push(mapper);
	}
	
	public function get mappers () : Array {
		return _mappers;
	}
	
	public function get xmlNames () : Array {
		var names:Array = new Array();
		for each (var mapper:XmlObjectMapper in _mappers) {
			names.push(mapper.elementName);
		}
		return names;
	}
	
				
}
}
