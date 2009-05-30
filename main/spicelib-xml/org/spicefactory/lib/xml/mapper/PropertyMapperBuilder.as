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
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.DefaultNamingStrategy;
import org.spicefactory.lib.xml.NamingStrategy;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.PropertyHandler;
import org.spicefactory.lib.xml.mapper.handler.AttributeHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildElementHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildTextNodeHandler;
import org.spicefactory.lib.xml.mapper.handler.ChoiceHandler;
import org.spicefactory.lib.xml.mapper.handler.TextNodeHandler;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class PropertyMapperBuilder {
	
	
	public static var defaultNamingStrategy:NamingStrategy = new DefaultNamingStrategy();

	public var namingStrategy:NamingStrategy;
	
	
	private var _objectType:ClassInfo;
	private var _elementName:QName;
	
	
	private var _ignoreUnmappedAttributes:Boolean = false;
	private var _ignoreUnmappedChildren:Boolean = false;
	private var _ignoredProperties:Dictionary = new Dictionary();
	
	
	private var propertyHandlerMap:Dictionary = new Dictionary();
	private var propertyHandlerList:Array = new Array();
	
	
	function PropertyMapperBuilder (objectType:Class, elementName:QName, namingStrategy:NamingStrategy = null,
			domain:ApplicationDomain = null) {
		this._objectType = ClassInfo.forClass(objectType, domain);
		this._elementName = elementName;
		this.namingStrategy = (namingStrategy != null) ? namingStrategy : defaultNamingStrategy;
	}
	
	
	public function get objectType () : ClassInfo {
		return _objectType;
	}
	
	public function get elementName () : QName {
		return _elementName;
	}	

	
	public function ignoreUnmappedAttributes () : void {
		_ignoreUnmappedAttributes = true;
	}
	
	public function ignoreUnmappedChildren () : void {
		_ignoreUnmappedChildren = true;
	}

	public function ignoreProperty (propertyName:String) : void {
		_ignoredProperties[propertyName] = true;
	}
	
	private function isMappableProperty (property:Property) : Boolean {
		return (property.writable 
				&& propertyHandlerMap[property.name] == undefined 
				&& _ignoredProperties[property.name] == undefined);
	}

	public function mapAllToAttributes () : void {
		for each (var property:Property in _objectType.getProperties()) {
			if (isMappableProperty(property)) {
				var attributeName:QName = new QName("", namingStrategy.toXmlName(property.name));
				addPropertyHandler(new AttributeHandler(property, attributeName));
			}
		}
	}
	
	public function mapToAttribute (propertyName:String, attributeName:QName = null) : void {
		if (attributeName == null) attributeName = new QName("", namingStrategy.toXmlName(propertyName));
		addPropertyHandler(new AttributeHandler(getProperty(propertyName), attributeName));
	}

	public function mapAllToChildTextNodes () : void {
		for each (var property:Property in _objectType.getProperties()) {
			if (isMappableProperty(property)) {
				var childName:QName = new QName(_elementName.uri, namingStrategy.toXmlName(property.name));
				addPropertyHandler(new ChildTextNodeHandler(property, childName));
			}
		}
	}
	
	public function mapToChildTextNode (propertyName:String, childName:QName = null) : void {
		if (childName == null) childName = new QName(_elementName.uri, namingStrategy.toXmlName(propertyName));
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
			type:Class = null, elementName:QName = null) : PropertyMapperBuilder {
		if (elementName == null) elementName = new QName(this._elementName.uri, namingStrategy.toXmlName(propertyName));
		var property:Property = getProperty(propertyName);
		if (type == null) type = property.type.getClass();
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, elementName, namingStrategy, _objectType.applicationDomain);
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
		var property:Property = _objectType.getProperty(propertyName);
		if (property == null || !property.writable) {
			throw new IllegalArgumentError("Property with name " + propertyName + " does not exist or is not writable"); 
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
		return new PropertyMapper(_objectType, _elementName, handlers, _ignoreUnmappedAttributes, _ignoreUnmappedChildren);
	}
	

}
}

import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.mapper.PropertyHandler;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.lib.xml.mapper.handler.AbstractPropertyHandler;
import org.spicefactory.lib.xml.mapper.handler.ChildElementHandler;

class BuilderHandler extends AbstractPropertyHandler {
	
	private var builder:PropertyMapperBuilder;
	
	function BuilderHandler (property:Property, xmlName:QName, builder:PropertyMapperBuilder) {
		super(property, "element", [xmlName], true);
		this.builder = builder;
	}
	
	public function createHandler () : PropertyHandler {
		return new ChildElementHandler(property, builder.build());
	}
}

