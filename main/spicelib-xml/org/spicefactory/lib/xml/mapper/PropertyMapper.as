package org.spicefactory.lib.xml.mapper {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.XmlValidationError;
import org.spicefactory.lib.xml.mapper.PropertyHandler;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class PropertyMapper implements XmlObjectMapper {

	
	private var _objectType:ClassInfo;
	private var _elementName:QName;
	
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
		_objectType = objectType;
		_elementName = elementName;
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
			if (handlerMap[xmlName] != undefined) {
				var message:String = "Duplicate handler registration for ";
				switch (handler.nodeKind) {
					case "attribute": message += "attribute with name " + xmlName; break;
					case "element": message += "child element with name " + xmlName; break;
					case "text": message += "text node"; break;
				}
				throw new XmlValidationError(message);
			}
			handlerMap[xmlName] = handler;
		}
	}

	
	public function get objectType () : ClassInfo {
		return _objectType;
	}
	
	public function get elementName () : QName {
		return _elementName;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		try {
			var targetInstance:Object = _objectType.newInstance([]);
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
			hasErrors = true;
			context.addError(error);
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
				valueMap[handlerMap[node.name().toString()]].push(node);
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
				unknownNodes.push(unknown.name().toString());
			}
			if (unknownNodes.length != 0) {
				throw new XmlValidationError("Element " + parentElement.name() 
					+ " contains one or more unmapped " + ((nodeKind == "attribute") ? "attributes" : "child elements")
					+ ": " + unknownNodes.join(",")); 
			}
		}
		
		// process nodes
		var hasErrors:Boolean = false;
		for (handler in valueMap) {
			try {
				handler.toObject(valueMap[handler], targetInstance);
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
	public function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		
		var parentElement:XML = <{elementName.localName}/>;
		if (elementName.uri != null && elementName.uri.length != 0) {
			context.setNamespace(parentElement, elementName.uri);
		}
		
		var hasErrors:Boolean = false;
		for each (var handler:PropertyHandler in propertyHandlerList) {
			try {
				handler.toXML(object, parentElement);
			}
			catch (e:Error) {
				hasErrors = true;
				context.addError(e);
			}
		}
		return (hasErrors) ? null : parentElement;
	}		 
	
		 
}

}
