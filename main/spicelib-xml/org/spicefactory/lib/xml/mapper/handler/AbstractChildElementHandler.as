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
