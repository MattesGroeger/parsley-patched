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

package org.spicefactory.parsley.xml.ext {
import org.spicefactory.parsley.xml.mapper.XmlObjectDefinitionMapperFactory;
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class XmlConfigurationNamespace {
	
	
	private var _uri:String;
	
	private var factories:Dictionary = new Dictionary();
	
	private var decorators:Dictionary = new Dictionary();
	
	
	function XmlConfigurationNamespace (uri:String) {
		_uri = uri;
	}
	
	
	public function get uri ():String {
		return _uri;
	}
	
	public function addCustomObjectMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName);
		checkNamspace(mapper);
		factories[mapper.elementName.localName] = mapper;
	}
	
	public function addCustomFactoryMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName, true);
		checkNamspace(mapper);
		factories[mapper.elementName.localName] = mapper;
	}
	
	public function addCustomDecoratorMapper (mapper:XmlObjectMapper) : void {
		validateDecorator(mapper.objectType, mapper.elementName.localName);
		checkNamspace(mapper);
		decorators[mapper.elementName.localName] = mapper;
	}

	public function addDefaultObjectMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(type), new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addCustomObjectMapper(builder.build());
	}
			
	public function addDefaultFactoryMapper (type:Class, tagName:String, decoratorArray:String = "decorators") : void {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName, decoratorArray);
		builder.mapAllToAttributes();
		addCustomFactoryMapper(builder.build());
	}

	public function addDefaultDecoratorMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(type), new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addCustomDecoratorMapper(builder.build());
	}

	private function newFactoryMapperBuilder (type:Class, tagName:String, decoratorArray:String = "decorators") : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		var elementName:QName = new QName(_uri, tagName);
		validateFactory(ci, tagName, true);
		return (decoratorArray == null) 
			? new PropertyMapperBuilder(ci, elementName) 
			: XmlObjectDefinitionMapperFactory.createObjectDefinitionFactoryMapperBuilder(ci, elementName, decoratorArray);
	}
	
	public function createObjectMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		validateFactory(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ci, new QName(_uri, tagName));
		factories[tagName] = builder;
		return builder;
	}

	public function createFactoryMapperBuilder (type:Class, tagName:String, decoratorArray:String = null) : PropertyMapperBuilder {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName, decoratorArray);
		factories[tagName] = builder;
		return builder;
	}
	
	public function createDecoratorMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		validateDecorator(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ci, new QName(_uri, tagName));
		decorators[tagName] = builder;
		return builder;
	}
	
	
	public function getAllFactoryMappers () : Array {
		return getAllMappers(factories);
	}
	
	public function getAllDecoratorMappers () : Array {
		return getAllMappers(decorators);
	}

	private function getAllMappers (map:Dictionary) : Array {
		var result:Array = new Array();
		for each (var dec:Object in map) {
			result.push(dec);
		}
		return result;
	}
	
	
	private function validateFactory (type:ClassInfo, tagName:String, mustBeFactory:Boolean = false) : void {
		if (factories[tagName] != null) {
			throw new IllegalArgumentError("Duplicate registration for object tag name " + tagName + " in namespace " + uri);
		}
		if (mustBeFactory && !type.isType(ObjectDefinitionFactory)) {
			throw new IllegalArgumentError("The specified factory class " + type.name 
					+ " does not implement the ObjectDefinitionFactory interface");
		}
	}
	
	private function validateDecorator (type:ClassInfo, tagName:String) : void {
		if (decorators[tagName] != null) {
			throw new IllegalArgumentError("Duplicate registration for decorator tag name " + tagName + " in namespace " + uri);
		}
		if (!type.isType(ObjectDefinitionDecorator)) {
			throw new IllegalArgumentError("The specified factory class " + type.name 
					+ " does not implement the ObjectDefinitionDecorator interface");
		}
	}
	
	private function checkNamspace (mapper:XmlObjectMapper) : void {
		if (mapper.elementName.uri != _uri) {
			throw new IllegalArgumentError("Namespace " + mapper.elementName.uri 
					+ " of mapper " + mapper + " does not match this configuration namespace: " + _uri);
		}		
	}
	
	
}
}
