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
	
	private var _ignoreUnmappedAttributes:Boolean = false;
	private var _ignoreUnmappedChildren:Boolean = false;
	
	private var attributeHandlerMap:Dictionary = new Dictionary();
	private var textNodeHandlerMap:Dictionary = new Dictionary();
	private var elementHandlerMap:Dictionary = new Dictionary();

	private var propertyHandlerMap:Dictionary = new Dictionary();
	private var propertyHandlerList:Array = new Array();


	function PropertyMapper (objectType:ClassInfo, elementName:QName, handlers:Array, 
			ignoreUnmappedAttributes:Boolean, ignoreUnmappedChildren:Boolean) {
		_objectType = objectType;
		_elementName = elementName;
		propertyHandlerList = handlers;
		// TODO - build other maps - check inconsistencies (no textNodeHandler AND elementHandler)
		_ignoreUnmappedAttributes = ignoreUnmappedAttributes;
		_ignoreUnmappedChildren = ignoreUnmappedChildren;
	}

	
	public function get objectType () : ClassInfo {
		return _objectType;
	}
	
	public function get elementName () : QName {
		return _elementName;
	}
	
	
	public function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		try {
			var targetInstance:Object = _objectType.newInstance([]);
			processNodes(element, element.attributes(), "attribute", attributeHandlerMap, targetInstance, context, _ignoreUnmappedAttributes);
			// TODO - process text nodes
			processNodes(element, element.children(), "element", elementHandlerMap, targetInstance, context, _ignoreUnmappedChildren);
		}
		catch (error:Error) {
			context.addError(error);
			return null;
		}
		return targetInstance;
	}
	
	
	private function processNodes (parentElement:XML, nodes:XMLList, nodeKind:String, handlerMap:Dictionary, 
			targetInstance:Object, context:XmlProcessorContext, ignoreUnmappedNodes:Boolean) : void {
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
						+ "' in node '" + parentElement.name() + "'");
			}
		}
		
		// optionally check unknown elements
		if (!ignoreUnmappedNodes) {
			// TODO - implement Error handling
		}
		
		// process nodes
		for (handler in valueMap) {
			handler.toObject(valueMap[handler], targetInstance);
			// TODO - catch errors here
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
