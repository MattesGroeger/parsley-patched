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
import org.spicefactory.lib.xml.mapper.XmlObjectMappings;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.tag.RootConfigurationTag;
import org.spicefactory.parsley.tag.core.ObjectDecoratorMarker;
import org.spicefactory.parsley.xml.mapper.XmlConfigurationNamespaceRegistry;

[Deprecated(replacement="XmlConfigurationNamespaceRegistry in package parsley.xml.mapper")]
/**
 * @author Jens Halm
 */
public class XmlConfigurationNamespace {
	
	private var _uri:String;
	private var mappings:XmlObjectMappings;
	
	
	function XmlConfigurationNamespace (uri:String) {
		_uri = uri;
		mappings = org.spicefactory.parsley.xml.mapper.XmlConfigurationNamespaceRegistry.getNamespace(uri);
	}

	public function get uri ():String {
		return _uri;
	}
	
	public function addCustomObjectMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName);
		checkNamespace(mapper);
		mappings.customMapper(mapper);
	}
	
	public function addCustomDefinitionFactoryMapper (mapper:XmlObjectMapper) : void {
		validateFactory(mapper.objectType, mapper.elementName.localName, true);
		checkNamespace(mapper);
		mappings.customMapper(mapper);
	}
	
	public function addCustomDecoratorMapper (mapper:XmlObjectMapper) : void {
		validateDecorator(mapper.objectType, mapper.elementName.localName);
		checkNamespace(mapper);
		mappings.customMapper(mapper);
	}

	public function addDefaultObjectMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addCustomObjectMapper(builder.build());
	}
	
	public function addDefaultDefinitionFactoryMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName);
		builder.mapAllToAttributes();
		addCustomDefinitionFactoryMapper(builder.build());
	}
	
	public function addDefaultDecoratorMapper (type:Class, tagName:String) : void {
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		builder.mapAllToAttributes();
		addCustomDecoratorMapper(builder.build());
	}

	private function newFactoryMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		var elementName:QName = new QName(_uri, tagName);
		validateFactory(ci, tagName, true);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, elementName);
		return builder;
	}
	
	public function createObjectMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		validateFactory(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		mappings.customMapper(builder.build());
		return builder;
	}

	public function createDefinitionFactoryMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var builder:PropertyMapperBuilder = newFactoryMapperBuilder(type, tagName);
		mappings.customMapper(builder.build());
		return builder;
	}
	
	public function createDecoratorMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		var ci:ClassInfo = ClassInfo.forClass(type);
		validateDecorator(ci, tagName);
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(type, new QName(_uri, tagName));
		mappings.customMapper(builder.build());
		return builder;
	}
	
	
	private function validateFactory (type:ClassInfo, tagName:String, mustBeFactory:Boolean = false) : void {
		if (mustBeFactory && !type.isType(ObjectDefinitionFactory) 
				&& !type.isType(RootConfigurationTag) && !type.isType(RootConfigurationElement)) {
			throw new IllegalArgumentError("The specified factory class " + type.name 
					+ " does not implement the RootConfigurationElement interface");
		}
	}
	
	private function validateDecorator (type:ClassInfo, tagName:String) : void {
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

