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
import org.spicefactory.lib.xml.mapper.PropertyHandler;

import flash.utils.Dictionary;

import flash.utils.getQualifiedClassName;/**
 * @author Jens Halm
 */
public class PropertyMapper extends AbstractXmlObjectMapper implements XmlObjectMapper {

	
	private var ignoreUnmappedAttributes:Boolean = false;
	private var ignoreUnmappedChildren:Boolean = false;
	
	private var expectsChildElements:Boolean = false;
	private var expectsTextNode:Boolean = false;
	
	private var attributeHandlerMap:Dictionary = new Dictionary();
	private var textNodeHandlerMap:Dictionary = new Dictionary();
	private var elementHandlerMap:Dictionary = new Dictionary();

	private var propertyHandlerList:Array = new Array();


	function PropertyMapper (objectType:ClassInfo, elementName:QName, handlers:Array, 
			ignoreUnmappedAttributes:Boolean, ignoreUnmappedChildren:Boolean) {
		super(objectType, elementName);
		propertyHandlerList = handlers;
		for each (var handler:PropertyHandler in propertyHandlerList) {
			switch (handler.nodeKind) {
				case "attribute":
					fillMap(attributeHandlerMap, handler);
					break;
				case "element":
					fillMap(elementHandlerMap, handler);
					expectsChildElements = true;
					break;
				case "text":
					fillMap(textNodeHandlerMap, handler);
					expectsTextNode = true;
					break;
				default:
					throw new XmlValidationError("Unknown or unsupported node kind: "  + handler.nodeKind);
			}
		}
		if (expectsChildElements && expectsTextNode) {
			throw new XmlValidationError("Processing mixed element content is not supported");
		}
		this.ignoreUnmappedAttributes = ignoreUnmappedAttributes;
		this.ignoreUnmappedChildren = ignoreUnmappedChildren;
	}

	private function fillMap (handlerMap:Dictionary, handler:PropertyHandler) : void {
		for each (var xmlName:QName in handler.xmlNames) {
			var key:String = (xmlName != null) ? xmlName.toString() : null;
			if (handlerMap[key] != undefined) {
				var message:String = "Duplicate handler registration for ";
				switch (handler.nodeKind) {
					case "attribute": message += "attribute with name " + xmlName; break;
					case "element": message += "child element with name " + xmlName; break;
					case "text": message += "text node"; break;
				}
				throw new XmlValidationError(message);
			}
			handlerMap[key] = handler;
		}
	}

	
	/**
	 * @inheritDoc
	 */
	public override function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		try {
			var targetInstance:Object = objectType.newInstance([]);
			var hasErrors:Boolean = false;
			hasErrors = processNodes(element, element.attributes(), "attribute", attributeHandlerMap, 
					targetInstance, context, ignoreUnmappedAttributes);
			if (expectsChildElements || (!expectsTextNode && !ignoreUnmappedChildren)) {
				hasErrors ||= processNodes(element, element.children(), "element", elementHandlerMap, 
						targetInstance, context, ignoreUnmappedChildren);
			}
			else if (expectsTextNode) {
				hasErrors ||= processNodes(element, element.children(), "text", textNodeHandlerMap, 
						targetInstance, context, ignoreUnmappedChildren);
			}
		}
		catch (error:Error) {
			trace(error.getStackTrace());
			hasErrors = true;
			context.addError(error);
		}
		if (hasErrors) {
			trace("Errors: " + context.errors.length);
			for each (var e:Object in context.errors) {
				trace("E " + e);
				var er:Error = e as Error;
				if (er is Error) trace(er.getStackTrace());
			}
		}
		return (hasErrors) ? null : targetInstance;
	}
	
	
	private function processNodes (parentElement:XML, nodes:XMLList, nodeKind:String, handlerMap:Dictionary, 
			targetInstance:Object, context:XmlProcessorContext, ignoreUnmappedNodes:Boolean) : Boolean {
		var handler:PropertyHandler;
		
		// prepare map
		var valueMap:Dictionary = new Dictionary();
		for each (handler in handlerMap) {
			valueMap[handler] = new Array();
		}
		valueMap[null] = new Array(); // collect unknown items here
		
		// map nodes to handlers
		for each (var node:XML in nodes) {
			if (node.nodeKind() == nodeKind) {
				var key:String = (node.name() != null) ? node.name().toString() : null;
				handler = handlerMap[key];
				valueMap[handler].push(node);
			}
			else if (node.nodeKind() != "processing-instruction" && node.nodeKind() != "comment") {
				throw new XmlValidationError("Unexpected node kind '" + node.nodeKind() 
						+ "' in element '" + parentElement.name() + "'");
			}
		}
		
		// optionally check unknown elements
		if (!ignoreUnmappedNodes) {
			var unknownNodes:Array = new Array();
			for each (var unknown:XML in valueMap[null]) {
				var unknownName:String = (unknown.name() != null) ? unknown.name().toString() : null;
				unknownNodes.push(unknownName);
			}
			if (unknownNodes.length != 0) {
				throw new XmlValidationError("Element " + parentElement.name() 
					+ " contains one or more unmapped " + ((nodeKind == "attribute") ? "attributes" : "child elements")
					+ ": " + unknownNodes.join(",")); 
			}
		}
		
		// process nodes
		var hasErrors:Boolean = false;
		for (var handlerObj:Object in valueMap) {
			if (handlerObj == "null") continue; // strangely null will be a String key here
			try {
				handler = handlerObj as PropertyHandler;
				handler.toObject(valueMap[handler], targetInstance, context);
			}
			catch (e:Error) {
				hasErrors = true;
				context.addError(e);
			}
		}
		return hasErrors;
	}
	
		 
	/**
	 * @inheritDoc
	 */
	public override function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		
		var parentElement:XML = <{elementName.localName}/>;
		if (elementName.uri != null && elementName.uri.length != 0) {
			context.setNamespace(parentElement, elementName.uri);
		}
		
		var hasErrors:Boolean = false;
		for each (var handler:PropertyHandler in propertyHandlerList) {
			try {
				handler.toXML(object, parentElement, context);
			}
			catch (e:Error) {
				hasErrors = true;
				context.addError(e);
			}
		}
		if (hasErrors) {
			trace("Errors: " + context.errors.length);
			for each (var er:Object in context.errors) {
				trace("E " + er);
				var err:Error = er as Error;
				if (err is Error) trace(err.getStackTrace());
			}
		}
		return (hasErrors) ? null : parentElement;
	}		 
	
		 
}

}
