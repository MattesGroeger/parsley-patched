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
import org.spicefactory.lib.xml.NamingStrategy;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.tag.RootConfigurationTag;
import org.spicefactory.parsley.tag.core.ObjectDecoratorMarker;
import org.spicefactory.parsley.xml.mapper.XmlObjectDefinitionMapperFactory;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

[Deprecated(replacement="XmlConfigurationNamespaceRegistry in package parsley.xml.mapper")]
/**
 * @author Jens Halm
 */
public class XmlConfigurationNamespace {
	
	private var _uri:String;
	
	private var _domain:ApplicationDomain;
	private var _namingStrategy:NamingStrategy;
	
	private var factories:Dictionary = new Dictionary();
	
	private var decorators:Dictionary = new Dictionary();
	
	function XmlConfigurationNamespace (uri:String, namingStrategy:NamingStrategy = null, domain:ApplicationDomain = null) {
		_uri = uri;
		_namingStrategy = namingStrategy;
		_domain = domain;
	}

	public function get uri ():String {
		return _uri;
	}
	
	public function addCustomObjectMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName);
		checkNamespace(mapper);
		factories[mapper.elementName.localName] = mapper;
	}
	
	public function addCustomDefinitionFactoryMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName, true);
		checkNamespace(mapper);
		factories[mapper.elementName.localName] = mapper;
	}
	
	public function addCustomDecoratorMapper (mapper:XmlObjectMapper) : void {
		validateDecorator(mapper.objectType, mapper.elementName.localName);
		checkNamespace(mapper);
		decorators[mapper.elementName.localName] = mapper;
	}

	public function addDefaultObjectMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName), _namingStrategy, _domain);
		builder.mapAllToAttributes();
		addCustomObjectMapper(builder.build());
	}
	
	public function addDefaultDefinitionFactoryMapper (type:Class, tagName:String, decoratorArray:String = null) : void {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName, decoratorArray);
		builder.mapAllToAttributes();
		//factories[tagName] = builder; ???
		addCustomDefinitionFactoryMapper(builder.build());
	}
	
	public function addDefaultDecoratorMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName), _namingStrategy, _domain);
		builder.mapAllToAttributes();
		addCustomDecoratorMapper(builder.build());
	}

	private function newFactoryMapperBuilder (type:Class, tagName:String, decoratorArray:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type, _domain);
		if (ci.isType(DefaultObjectDefinitionFactory)) decoratorArray = "decorators";
		var elementName:QName = new QName(_uri, tagName);
		validateFactory(ci, tagName, true);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, elementName, _namingStrategy, _domain);
		if (decoratorArray != null) builder.mapToChildElementChoice(decoratorArray, XmlObjectDefinitionMapperFactory.getDecoratorChoice());
		return builder;
	}
	
	public function createObjectMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type, _domain);
		validateFactory(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		factories[tagName] = builder.build();
		return builder;
	}

	public function createDefinitionFactoryMapperBuilder (type:Class, tagName:String, decoratorArray:String = null) : PropertyMapperBuilder {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName, decoratorArray);
		factories[tagName] = builder.build();
		return builder;
	}
	
	public function createDecoratorMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type, _domain);
		validateDecorator(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		decorators[tagName] = builder.build();
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
		if (mustBeFactory && !type.isType(ObjectDefinitionFactory) 
				&& !type.isType(RootConfigurationTag) && !type.isType(RootConfigurationElement)) {
			throw new IllegalArgumentError("The specified factory class " + type.name 
					+ " does not implement the RootConfigurationElement interface");
		}
	}
	
	private function validateDecorator (type:ClassInfo, tagName:String) : void {
		if (decorators[tagName] != null) {
			throw new IllegalArgumentError("Duplicate registration for decorator tag name " + tagName + " in namespace " + uri);
		}
		if (!type.isType(ObjectDecoratorMarker)) {
			throw new IllegalArgumentError("The specified decorator class " + type.name 
					+ " does not implement the ObjectDefinitionDecorator interface");
		}
	}
	
	private function checkNamespace (mapper:XmlObjectMapper) : void {
		if (mapper.elementName.uri != _uri) {
			throw new IllegalArgumentError("Namespace " + mapper.elementName.uri 
					+ " of mapper " + mapper + " does not match this configuration namespace: " + _uri);
		}		
	}
}
}

