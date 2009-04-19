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
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.XmlProcessorContext;

/**
 * @author Jens Halm
 */
public class AbstractChildElementHandler extends AbstractPropertyHandler {
	
	
	public function AbstractChildElementHandler (property:Property, xmlNames:Array) {
		super(property, "element", xmlNames, true);
	}
	
	
	public override function toObject (nodes:Array, parentInstance:Object, context:XmlProcessorContext) : void {
		validateValueCount(nodes.length);
		if (nodes.length > 0) {
			if (singleValue) {
				var object:Object = mapToObject(nodes[0], context);
				if (object != null) {
					property.setValue(parentInstance, object);
				}
			}
			else {
				var array:Array = new Array();
				for each (var node:XML in nodes) {
					var element:Object = mapToObject(node, context);
					if (element != null) {
						array.push(element); 
					}
				}
				property.setValue(parentInstance, array);
			}
		}
	}
	
	private function mapToObject (node:XML, context:XmlProcessorContext) : Object {
		return getMapperForXmlName(node.name() as QName).mapToObject(node, context);
	}
	
		
	public override function toXML (instance:Object, parentElement:XML, context:XmlProcessorContext) : void {
		var value:Object = getValue(instance);
		if (value is Array) {
			for each (var element:Object in value) {
				mapToXML(element, parentElement, context);
			}
		}
		else {
			mapToXML(value, parentElement, context);
		}
	}
	
	private function mapToXML (value:Object, parentElement:XML, context:XmlProcessorContext) : void {
		if (value != null) {
			var child:XML = getMapperForInstance(value, context).mapToXml(value, context);
			if (child != null) {
				parentElement.appendChild(child);
			}
		}
	}
	
	
	
	protected function getMapperForInstance (instance:Object, context:XmlProcessorContext):XmlObjectMapper {
		throw new AbstractMethodError();
	}
	
	protected function getMapperForXmlName (xmlName:QName) : XmlObjectMapper {
		throw new AbstractMethodError();
	}
	
	
}
}
