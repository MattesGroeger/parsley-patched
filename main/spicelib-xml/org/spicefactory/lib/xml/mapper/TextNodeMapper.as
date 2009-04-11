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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.XmlValidationError;
import org.spicefactory.lib.xml.impl.ValueConfig;

/**
 * @author Jens Halm
 */
public class TextNodeMapper extends AbstractStringValueMapper implements XmlObjectMapper {
	
	
	private var _ignoreUnmappedChildNodes:Boolean = false;
	private var _ignoreAttributes:Boolean = false;
	
	
	function TextNodeMapper (targetType:ClassInfo, namespaceUri:String = null) {
		super(targetType, namespaceUri);
	}
	
	
	public function ignoreUnmappedChildNodes () : void {
		_ignoreUnmappedChildNodes = true;
	}
	
	public function ignoreAttributes () : void {
		_ignoreAttributes = true;
	}	
	
	
	/**
	 * @inheritDoc
	 */
	public function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		try {
			var targetInstance:Object = targetType.newInstance([]);
			processChildren(element, targetInstance, context);
			return targetInstance;
		}
		catch (error:Error) {
			context.addError(error);
			return null;
		}
	}
	
	protected function processChildren (element:XML, targetInstance:Object, context:XmlProcessorContext) : void {
		// check for unexpected attributes
		if (!_ignoreAttributes) {
			if (element.attributes().length() > 0) {
				throw new XmlValidationError("Unexpected attributes in element: " + element.nodeName());
			}
		}
		// check for unexpected child nodes
		if (!_ignoreUnmappedChildNodes) {
			var children:XMLList = element.children();
			for each (var child:XML in children) {
				if (child.nodeKind() == "text") {
					throw new XmlValidationError("Unexpected text node in element: " + element.nodeName());
				}
				if (child.nodeKind() != "element") {
					continue;
				}
				var qName:QName = child.name() as QName;
				if (getXmlConfig(qName.toString()) == null) {
					throw new XmlValidationError("Unexpected child node '" + qName.toString() 
							+ "' in element: " + element.nodeName());
				}
			}
		}
		// check all permitted attributes
		for each (var config:ValueConfig in getAllConfigs()) {
			children = element.elements(config.xmlName);
			if (children.length() == 0 && config.required) { 
				throw new XmlValidationError("Missing required child node '" + config.xmlName 
						+ " in element: " + element.nodeName());
			}
			else if (children.length() > 1) {
				throw new XmlValidationError("Expected at most one child node '" + config.xmlName 
						+ " in element: " + element.nodeName());
			}
			config.property.setValue(targetInstance, context.expressionContext.createExpression(children[0]).value);
		}
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		return null; // TODO - map to XML
	}
	
	
}

}
