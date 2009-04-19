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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.Choice;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.factory.decorator.AsyncInitDecorator;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.messaging.decorator.ManagedEventsDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageBindingDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageHandlerDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageInterceptorDecorator;
import org.spicefactory.parsley.xml.tag.ObjectDefinitionFactoryContainer;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionMapperFactory {
	

	public static const PARSLEY_NAMESPACE_URI:String = "http://www.spicefactory.org/parsley";
	
	private var rootObjectChoice:Choice;

	private var decoratorChoice:Choice;

	private var valueChoice:Choice;
	
	
	public function createObjectDefinitionMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(ObjectDefinitionFactoryContainer, "objects"); 
		rootObjectChoice = new Choice();
		rootObjectChoice.addMapper(getRootObjectMapper());
		builder.mapToChildElementChoice("factories", rootObjectChoice);
		return builder.build();
	}
	
	
	private function getRootObjectMapper () : XmlObjectMapper {
		var builder:PropertyMapperBuilder = getMapperBuilder(DefaultObjectDefinitionFactory, "object"); 
		
		addDecoratorAttributeMapper(AsyncInitDecorator, "asyncInit");

		addDecoratorAttributeMapper(MessageHandlerDecorator, "message-handler");
		addDecoratorAttributeMapper(MessageInterceptorDecorator, "message-interceptor");
		addDecoratorAttributeMapper(MessageBindingDecorator, "message-binding");
		addDecoratorAttributeMapper(ManagedEventsDecorator, "managed-events");
		return builder.build();
	}
	
	private function addDecoratorAttributeMapper (type:Class, tagName:String) : void {
		var childBuilder:PropertyMapperBuilder = getMapperBuilder(type, tagName);
		childBuilder.mapAllToAttributes();
		decoratorChoice.addMapper(childBuilder.build());
	}
	
	private function getMapperBuilder (type:Class, tagName:String) : PropertyMapperBuilder {
		return new PropertyMapperBuilder(ClassInfo.forClass(type), 
				new QName(PARSLEY_NAMESPACE_URI, tagName));
	}
	
	
	
}
}
