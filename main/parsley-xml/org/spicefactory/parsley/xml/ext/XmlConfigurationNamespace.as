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
	
	public function addFactoryMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName);
		checkNamspace(mapper);
		factories[mapper.elementName.localName] = mapper;
	}
	
	public function addDecoratorMapper (mapper:XmlObjectMapper) : void {
		validateDecorator(mapper.objectType, mapper.elementName.localName);
		checkNamspace(mapper);
		decorators[mapper.elementName.localName] = mapper;
	}
		
	public function addDefaultFactoryMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(type), new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addFactoryMapper(builder.build());
	}
	
	public function addDefaultDecoratorMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(type), new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addDecoratorMapper(builder.build());
	}

	public function createFactoryMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		validateFactory(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ci, new QName(_uri, tagName));
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
			if (dec is PropertyMapperBuilder) {
				dec = PropertyMapperBuilder(dec).build(); 
			}
			result.push(dec);
		}
		return result;
	}
	
	
	private function validateFactory (type:ClassInfo, tagName:String) : void {
		if (factories[tagName] != null) {
			throw new IllegalArgumentError("Duplicate registration for factory tag name " + tagName + " in namespace " + uri);
		}
		if (!type.isType(ObjectDefinitionFactory)) {
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
