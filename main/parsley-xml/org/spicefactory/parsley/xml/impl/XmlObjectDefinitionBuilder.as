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
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.xml.tag.ObjectDefinitionFactoryContainer;

import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionBuilder extends EventDispatcher implements AsyncObjectDefinitionBuilder {

	
	private var mapper:XmlObjectMapper; // TODO - create mapper
	private var _loader:XmlObjectDefinitionLoader;
	private var files:Array;
	private var xmlRoots:Array;
	private var expressionContext:ExpressionContext;

	
	function XmlObjectDefinitionBuilder (files:Array, expressionContext:ExpressionContext) {
		this.files = files;
		this.expressionContext = expressionContext;
	}

	
	public function get loader () : XmlObjectDefinitionLoader {
		return _loader;
	}
	
	public function addXml (xml:XML) : void {
		xmlRoots.push(xml);
	}
	
	public function build (registry:ObjectDefinitionRegistry) : void {
		var context:XmlProcessorContext = new XmlProcessorContext(expressionContext, registry.domain);
		for each (var containerXML:XML in xmlRoots) {
			var container:ObjectDefinitionFactoryContainer 
					= mapper.mapToObject(containerXML, context) as ObjectDefinitionFactoryContainer;
			if (container != null) {
				for each (var factory:ObjectDefinitionFactory in container.factories) {
					try {
						var definition:RootObjectDefinition = factory.createRootDefinition(registry);
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
	
	public function cancel () : void {
		// TODO - implement cancel method
	}
	
	
}
}
