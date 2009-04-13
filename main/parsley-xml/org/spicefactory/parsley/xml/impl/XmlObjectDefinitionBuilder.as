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

package org.spicefactory.parsley.xml.impl {
	import org.spicefactory.parsley.xml.tag.ObjectDefinitionFactoryContainer;
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.core.impl.MetadataObjectDefinitionBuilder;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionBuilder {
	
	
	private var builder:MetadataObjectDefinitionBuilder = new MetadataObjectDefinitionBuilder();
	
	private var mapper:XmlObjectMapper; // TODO - create mapper

	
	public function build (containers:Array, registry:ObjectDefinitionRegistry, expressionContext:ExpressionContext = null):void {
		var context:XmlProcessorContext = new XmlProcessorContext(expressionContext, registry.domain);
		for each (var containerXML:XML in containers) {
			var container:ObjectDefinitionFactoryContainer 
					= mapper.mapToObject(containerXML, context) as ObjectDefinitionFactoryContainer;
			if (container != null) {
				for each (var factory:ObjectDefinitionFactory in container.factories) {
					try {
						var definition:RootObjectDefinition = factory.createRootDefinition(registry);
						builder.processMetadata(registry, definition);
						factory.applyDecorators(definition, registry);
						registry.registerDefinition(definition);
					} 
					catch (error:Error) {
						context.addError(error);
					}
				}
			}	
		}
		if (context.hasErrors()) {
			var msg:String = "XML Context configuration contains one or more errors: ";
			for each (var e:Error in context.errors) msg += "\n" + e.message; 
			throw new ContextError(msg);
		}
	}
	
	
}
}
