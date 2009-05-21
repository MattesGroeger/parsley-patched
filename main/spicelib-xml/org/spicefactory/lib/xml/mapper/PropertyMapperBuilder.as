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
import org.spicefactory.lib.xml.DefaultNamingStrategy;
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.NamingStrategy;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.PropertyHandler;
import org.spicefactory.lib.xml.mapper.handler.AttributeHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildElementHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildTextNodeHandler;
import org.spicefactory.lib.xml.mapper.handler.ChoiceHandler;
import org.spicefactory.lib.xml.mapper.handler.TextNodeHandler;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class PropertyMapperBuilder {
	
	
	public static var defaultNamingStrategy:NamingStrategy = new DefaultNamingStrategy();

	public var namingStrategy:NamingStrategy;
	
	
	private var objectType:ClassInfo;
	private var elementName:QName;
	
	
	private var _ignoreUnmappedAttributes:Boolean = false;
	private var _ignoreUnmappedChildren:Boolean = false;
	
	
	private var propertyHandlerMap:Dictionary = new Dictionary();
	private var propertyHandlerList:Array = new Array();
	
	
	function PropertyMapperBuilder (objectType:ClassInfo, elementName:QName, namingStrategy:NamingStrategy = null) {
		this.objectType = objectType;
		this.elementName = elementName;
		this.namingStrategy = (namingStrategy != null) ? namingStrategy : defaultNamingStrategy;
	}

	
	public function ignoreUnmappedAttributes () : void {
		_ignoreUnmappedAttributes = true;
	}
	
	public function ignoreUnmappedChildren () : void {
		_ignoreUnmappedChildren = true;
	}

	
	public function mapAllToAttributes () : void {
		for each (var property:Property in objectType.getProperties()) {
			if (property.writable && propertyHandlerMap[property.name] == undefined) {
				var attributeName:QName = new QName(null, namingStrategy.toXmlName(property.name));
				addPropertyHandler(new AttributeHandler(property, attributeName));
			}
		}
	}
	
	public function mapToAttribute (propertyName:String, attributeName:QName = null) : void {
		if (attributeName == null) attributeName = new QName(null, namingStrategy.toXmlName(propertyName));
		addPropertyHandler(new AttributeHandler(getProperty(propertyName), attributeName));
	}

	public function mapAllToChildTextNodes () : void {
		for each (var property:Property in objectType.getProperties()) {
			if (property.writable && propertyHandlerMap[property.name] == undefined) {
				var childName:QName = new QName(elementName.uri, namingStrategy.toXmlName(property.name));
				addPropertyHandler(new ChildTextNodeHandler(property, childName));
			}
		}
	}
	
	public function mapToChildTextNode (propertyName:String, childName:QName = null) : void {
		if (childName == null) childName = new QName(elementName.uri, namingStrategy.toXmlName(propertyName));
		addPropertyHandler(new ChildTextNodeHandler(getProperty(propertyName), childName));
	}
	
	public function mapToTextNode (propertyName:String) : void {
		addPropertyHandler(new TextNodeHandler(getProperty(propertyName)));
	}
	
	public function mapToChildElement (propertyName:String, mapper:XmlObjectMapper) : void {
		addPropertyHandler(new ChildElementHandler(getProperty(propertyName), mapper));
	}
	
	public function mapToChildElementChoice (propertyName:String, choice:Choice) : void {
		addPropertyHandler(new ChoiceHandler(getProperty(propertyName), choice));
	}

	public function createChildElementMapperBuilder (propertyName:String, 
			type:ClassInfo = null, elementName:QName = null) : PropertyMapperBuilder {
		if (elementName == null) elementName = new QName(this.elementName.uri, namingStrategy.toXmlName(propertyName));
		var property:Property = getProperty(propertyName);
		if (type == null) type = property.type;
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, elementName);
		addPropertyHandler(new BuilderHandler(getProperty(propertyName), elementName, builder));
		return builder;
	}
	
	public function addPropertyHandler (handler:PropertyHandler) : void {
		if (propertyHandlerMap[handler.property.name] != undefined) {
			propertyHandlerList.splice(propertyHandlerList.indexOf(propertyHandlerMap[handler.property.name]), 1);
		}
		propertyHandlerMap[handler.property.name] = handler;
		propertyHandlerList.push(handler);
	}

	
	protected function getProperty (propertyName:String) : Property {
		var property:Property = objectType.getProperty(propertyName);
		if (property == null || !property.writable) {
			throw new IllegalArgumentError("Property with name " + property + " does not exist or is not writable"); 
		}		
		return property;
	}
	
	
	public function build () : PropertyMapper {
		var handlers:Array = new Array();
		for each (var handler:PropertyHandler in propertyHandlerList) {
			if (handler is BuilderHandler) {
				handlers.push(BuilderHandler(handler).createHandler());
			}
			else {
				handlers.push(handler);
			}
		}
		return new PropertyMapper(objectType, elementName, handlers, _ignoreUnmappedAttributes, _ignoreUnmappedChildren);
	}
	
	
}
}

import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.mapper.handler.AbstractPropertyHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildElementHandler;
import org.spicefactory.lib.xml.mapper.PropertyHandler;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;

class BuilderHandler extends AbstractPropertyHandler {
	
	private var builder:PropertyMapperBuilder;
	
	function BuilderHandler (property:Property, xmlName:QName, builder:PropertyMapperBuilder) {
		super(property, "element", [xmlName]);
		this.builder = builder;
	}
	
	public function createHandler () : PropertyHandler {
		return new ChildElementHandler(property, builder.build());
	}
}

