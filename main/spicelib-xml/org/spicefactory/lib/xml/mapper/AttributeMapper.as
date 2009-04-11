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
import org.spicefactory.lib.expr.Expression;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.XmlValidationError;
import org.spicefactory.lib.xml.impl.ValueConfig;

/**
 * @author Jens Halm
 */
public class AttributeMapper extends AbstractStringValueMapper implements XmlObjectMapper {


	public static const SCHEMA_NAMESPACE_URI:String = "http://www.w3.org/2001/XMLSchema-instance";
	
	
	private var _ignoreUnmappedAttributes:Boolean = false;
	private var _ignoreChildNodes:Boolean = false;
	
	
	function AttributeMapper (targetType:ClassInfo) {
		super(targetType);
	}
	

	public function ignoreUnmappedAttributes () : void {
		_ignoreUnmappedAttributes = true;
	}
	
	public function ignoreChildNodes () : void {
		_ignoreChildNodes = true;
	}

	
	/**
	 * @inheritDoc
	 */
	public function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		try {
			var targetInstance:Object = targetType.newInstance([]);
			processAttributes(element, targetInstance, context);
			return targetInstance;
		}
		catch (error:Error) {
			context.addError(error);
			return null;
		}
	}
	
	protected function processAttributes (element:XML, targetInstance:Object, context:XmlProcessorContext) : void {
		// check for unexpected child nodes
		if (!_ignoreChildNodes) {
			if (element.children().length() > 0) {
				throw new XmlValidationError("Unexpected child nodes in element: " + element.nodeName());
			}
		}
		// check for unexpected attributes
		if (!_ignoreUnmappedAttributes) {
			var attList:XMLList = element.attributes();
			for each (var attr:XML in attList) {
				var qName:QName = attr.name() as QName;
				if (qName.uri == SCHEMA_NAMESPACE_URI) continue; // ignore
				if (getXmlConfig(qName.toString()) == null) {
					throw new XmlValidationError("Unexpected attribute '" + qName.localName 
							+ "' in element: " + element.nodeName());
				}
			}
		}
		// check all permitted attributes
		for each (var config:ValueConfig in getAllConfigs()) {
			attList = element.attribute(config.xmlName);
			if (attList.length() == 0 && config.required) { 
				throw new XmlValidationError("Missing required attribute '" + config.xmlName 
						+ " in element: " + element.nodeName());
			}
			config.property.setValue(targetInstance, context.expressionContext.createExpression(attList[0]).value);
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
