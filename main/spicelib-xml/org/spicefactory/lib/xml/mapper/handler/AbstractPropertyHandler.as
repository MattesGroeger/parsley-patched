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
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.metadata.Required;
import org.spicefactory.lib.xml.mapper.PropertyHandler;

/**
 * @author Jens Halm
 */
public class AbstractPropertyHandler implements PropertyHandler {
	
	
	private var _property:Property;
	private var _xmlNames:Array;
	private var _nodeKind:String;
	private var _required:Boolean;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param attributeName the local name of the attribute
	 * @param property the property the attribute value should be applied to
	 * @param required whether this attribute is required
	 */
	public function AbstractPropertyHandler (property:Property, nodeKind:String, xmlNames:Array = null) {
		_property = property;
		_required = property.getMetadata(Required).length > 0;
		_nodeKind = nodeKind;
		_xmlNames = (xmlNames == null) ? [null] : xmlNames;
	}
	
	/**
	 * The Property the attribute should map to.
	 */
	public function get property () : Property {
		return _property;
	}
	
	/**
	 * The local name of the attribute.
	 */
	public function get xmlNames () : Array {
		return _xmlNames;
	}
	
	/**
	 * The kind of node this handler deals with.
	 * Valid values are element, attribute and text.
	 */
	public function get nodeKind () : String {
		return _nodeKind;
	}
	
	/**
	 * Indicates whether this attribute is required.
	 */
	public function get required () : Boolean {
		return _required;
	}
	
	public function toObject (node:XML, parentInstance:Object) : void {
		throw new AbstractMethodError();
	}
	
	public function toXML (instance:Object, parentElement:XML) : void {
		throw new AbstractMethodError();
	}
	

}
}
