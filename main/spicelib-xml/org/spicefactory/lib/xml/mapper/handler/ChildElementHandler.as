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

package org.spicefactory.lib.xml.mapper.handler {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;

/**
 * @author Jens Halm
 */
public class ChildElementHandler extends AbstractChildElementHandler {


	private var mapper:XmlObjectMapper;

	
	public function ChildElementHandler (property:Property, mapper:XmlObjectMapper) {
		super(property, [mapper.elementName]);
		this.mapper = mapper;
	}
	
	
	protected override function getMapperForInstance (instance:Object, context:XmlProcessorContext) : XmlObjectMapper {
		return mapper;
	}
	
	protected override function getMapperForXmlName (xmlName:QName) : XmlObjectMapper {
		return mapper;
	}
	

}
}
