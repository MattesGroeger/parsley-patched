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

package org.spicefactory.parsley.xml.mapper {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.ClassConverter;
import org.spicefactory.lib.reflect.converter.DateConverter;
import org.spicefactory.lib.reflect.converter.IntConverter;
import org.spicefactory.lib.reflect.converter.NumberConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.reflect.converter.UintConverter;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.Choice;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.factory.decorator.AsyncInitDecorator;
import org.spicefactory.parsley.factory.decorator.FactoryMethodDecorator;
import org.spicefactory.parsley.factory.decorator.PostConstructMethodDecorator;
import org.spicefactory.parsley.factory.decorator.PreDestroyMethodDecorator;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.factory.tag.ArrayTag;
import org.spicefactory.parsley.factory.tag.ConstructorDecoratorTag;
import org.spicefactory.parsley.factory.tag.ObjectReferenceTag;
import org.spicefactory.parsley.factory.tag.PropertyDecoratorTag;
import org.spicefactory.parsley.messaging.decorator.ManagedEventsDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageBindingDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageHandlerDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageInterceptorDecorator;
import org.spicefactory.parsley.resources.ResourceBindingDecorator;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespace;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespaceRegistry;
import org.spicefactory.parsley.xml.tag.Include;
import org.spicefactory.parsley.xml.tag.ObjectDefinitionFactoryContainer;
import org.spicefactory.parsley.xml.tag.StaticPropertyRef;
import org.spicefactory.parsley.xml.tag.Variable;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionMapperFactory {
	

	public static const PARSLEY_NAMESPACE_URI:String = "http://www.spicefactory.org/parsley";

	
	private var rootObjectChoice:Choice = new Choice();

	private var decoratorChoice:Choice = new Choice();

	private var valueChoice:Choice = new Choice();
	
	
	
	public static function createObjectDefinitionFactoryMapperBuilder (objectType:ClassInfo, 
			elementName:QName, decoratorArray:String) : PropertyMapperBuilder {
		return new ObjectDefinitionFactoryMapperBuilder(objectType, elementName, decoratorArray);
	}

	
	public function createObjectDefinitionMapper () : XmlObjectMapper {
		addCustomConfigurationNamespaces();
		buildValueChoice();
		buildDecoratorChoice();
		var builder:PropertyMapperBuilder = getMapperBuilder(ObjectDefinitionFactoryContainer, "objects"); 
		rootObjectChoice.addMapper(getRootObjectMapper());
		builder.mapToChildElementChoice("objects", rootObjectChoice);
		return builder.build();
	}
	
	public function createVariableMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(Variable, "variable");
		builder.mapAllToAttributes();
		return builder.build(); 
	}
	
	public function createIncludeMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(Include, "include");
		builder.mapAllToAttributes();
		return builder.build(); 		
	}

	
	private function getRootObjectMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(DefaultObjectDefinitionFactory, "object"); 
		builder.mapToChildElementChoice("decorators", decoratorChoice);
		builder.mapAllToAttributes();
		return builder.build();
	}
	
	private function getNestedObjectMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(DefaultObjectDefinitionFactory, "object"); 
		builder.mapToChildElementChoice("decorators", decoratorChoice);
		builder.mapToAttribute("type");
		return builder.build();
	}
	
	
	private function addCustomConfigurationNamespaces () : void {
		var namespaces:Array = XmlConfigurationNamespaceRegistry.getRegisteredNamespaces();
		for each (var ns:XmlConfigurationNamespace in namespaces) {
			var factories:Array = ns.getAllFactoryMappers();
			for each (var fObj:Object in factories) {
				var fMapper:XmlObjectMapper = getCustomMapper(fObj);
				rootObjectChoice.addMapper(fMapper);
				valueChoice.addMapper(fMapper);
			}
			var decorators:Array = ns.getAllFactoryMappers();
			for each (var dObj:Object in decorators) {
				var dMapper:XmlObjectMapper = getCustomMapper(dObj);
				decoratorChoice.addMapper(dMapper);
			}
		}
	}
	
	private function getCustomMapper (obj:Object) : XmlObjectMapper {
		if (obj is XmlObjectMapper) {
			return obj as XmlObjectMapper;
		}
		else if (obj is ObjectDefinitionFactoryMapperBuilder) {
			var factoryBuilder:ObjectDefinitionFactoryMapperBuilder = obj as ObjectDefinitionFactoryMapperBuilder;
			factoryBuilder.applyDecoratorChoice(decoratorChoice);
			return factoryBuilder.build();
		}
		else if (obj is PropertyMapperBuilder) {
			return PropertyMapperBuilder(obj).build();
		}
		else {
			throw new IllegalArgumentError("Object type " + getQualifiedClassName(obj) 
					+ " is neither an XmlObjectMapper nor a PropertyMapperBuilder");	
		}
	}

	
	private function buildDecoratorChoice () : void {
		var childBuilder:PropertyMapperBuilder = getMapperBuilder(ConstructorDecoratorTag, "constructor-args");
		childBuilder.mapToChildElementChoice("values", valueChoice);
		decoratorChoice.addMapper(childBuilder.build());
		
		childBuilder = getMapperBuilder(PropertyDecoratorTag, "property");
		childBuilder.mapToChildElementChoice("childValue", valueChoice);
		childBuilder.mapAllToAttributes();
		decoratorChoice.addMapper(childBuilder.build());

		addDecoratorAttributeMapper(AsyncInitDecorator, "asyncInit");

		addDecoratorAttributeMapper(FactoryMethodDecorator, "factory");
		addDecoratorAttributeMapper(PostConstructMethodDecorator, "post-construct");
		addDecoratorAttributeMapper(PreDestroyMethodDecorator, "pre-destroy");
		
		addDecoratorAttributeMapper(MessageHandlerDecorator, "message-handler");
		addDecoratorAttributeMapper(MessageInterceptorDecorator, "message-interceptor");
		addDecoratorAttributeMapper(MessageBindingDecorator, "message-binding");
		addDecoratorAttributeMapper(ManagedEventsDecorator, "managed-events");

		addDecoratorAttributeMapper(ResourceBindingDecorator, "resource-binding");
	}
	
	private function addDecoratorAttributeMapper (type:Class, tagName:String) : void {
		var childBuilder:PropertyMapperBuilder = getMapperBuilder(type, tagName);
		childBuilder.mapAllToAttributes();
		decoratorChoice.addMapper(childBuilder.build());
	}
	
	
	private function buildValueChoice () : void {
		valueChoice.addMapper(new NullXmlObjectMapper());
		
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(Boolean, "boolean", BooleanConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(Number, "number", NumberConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(int, "int", IntConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(uint, "uint", UintConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(String, "string", StringConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(Date, "date", DateConverter.INSTANCE));
		valueChoice.addMapper(new SimpleValueXmlObjectMapper(Class, "class", ClassConverter.INSTANCE));

		var childBuilder:PropertyMapperBuilder = getMapperBuilder(ArrayTag, "array");
		childBuilder.mapToChildElementChoice("values", valueChoice);
		valueChoice.addMapper(childBuilder.build());
		
		addValueAttributeMapper(StaticPropertyRef, "static-property");
		addValueAttributeMapper(ObjectReferenceTag, "object-ref");
		
		valueChoice.addMapper(getNestedObjectMapper());
	}
	
	private function addValueAttributeMapper (type:Class, tagName:String) : void {
		var childBuilder:PropertyMapperBuilder = getMapperBuilder(type, tagName);
		childBuilder.mapAllToAttributes();
		valueChoice.addMapper(childBuilder.build());		
	}
	
	
	private function getMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		return new PropertyMapperBuilder(ClassInfo.forClass(type), 
				new QName(PARSLEY_NAMESPACE_URI, tagName));
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.lib.reflect.types.Any;
import org.spicefactory.lib.xml.NamingStrategy;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.mapper.AbstractXmlObjectMapper;
import org.spicefactory.lib.xml.mapper.Choice;
import org.spicefactory.lib.xml.mapper.PropertyMapper;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.xml.tag.StaticPropertyRef;

import flash.errors.IllegalOperationError;

class NullXmlObjectMapper extends AbstractXmlObjectMapper {
	
	function NullXmlObjectMapper () {
		super(null, new QName(XmlObjectDefinitionMapperFactory.PARSLEY_NAMESPACE_URI, "null"));
	}
	
	public override function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		return null;
	}

	public override function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		throw new IllegalOperationError("This mapper does not support mapping back to XML");
	}
	 
}

class SimpleValueXmlObjectMapper extends AbstractXmlObjectMapper {
	
	private var converter:Converter;
	
	function SimpleValueXmlObjectMapper (type:Class, tagName:String, converter:Converter) {
		super(ClassInfo.forClass(type), new QName(XmlObjectDefinitionMapperFactory.PARSLEY_NAMESPACE_URI, tagName));
		this.converter = converter;
	}
	
	public override function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		return converter.convert(context.expressionContext.createExpression(element.text()[0]).value);
	}

	public override function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		throw new IllegalOperationError("This mapper does not support mapping back to XML");
	}
	
}

class StaticPropertyRefMapper extends AbstractXmlObjectMapper {
	
	private var delegate:PropertyMapper;
	
	function StaticPropertyRefMapper () {
		super(ClassInfo.forClass(Any), new QName(XmlObjectDefinitionMapperFactory.PARSLEY_NAMESPACE_URI, "static-property"));
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(StaticPropertyRef), elementName);
		builder.mapAllToAttributes();
		delegate = builder.build();
	}
	
	public override function mapToObject (element:XML, context:XmlProcessorContext) : Object {
		var ref:StaticPropertyRef = delegate.mapToObject(element, context) as StaticPropertyRef;
		return (ref != null) ? ref.resolve(context.applicationDomain) : null;
	}

	public override function mapToXml (object:Object, context:XmlProcessorContext) : XML {
		throw new IllegalOperationError("This mapper does not support mapping back to XML");
	}	
	
	
}

class ObjectDefinitionFactoryMapperBuilder extends PropertyMapperBuilder {
	
	private var decoratorArray:String;
	
	function ObjectDefinitionFactoryMapperBuilder (objectType:ClassInfo, elementName:QName, 
			decoratorArray:String, namingStrategy:NamingStrategy = null) {
		super(objectType, elementName, namingStrategy);
		this.decoratorArray = decoratorArray;
	}
	
	public function applyDecoratorChoice (choice:Choice) : void {
		mapToChildElementChoice(decoratorArray, choice);
	}
	
	
}

