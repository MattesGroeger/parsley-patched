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

package org.spicefactory.parsley.xml.builder {
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.xml.builder.XmlObjectDefinitionLoader;
import org.spicefactory.parsley.xml.mapper.XmlObjectDefinitionMapperFactory;
import org.spicefactory.parsley.xml.tag.ObjectDefinitionFactoryContainer;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionBuilder extends EventDispatcher implements AsyncObjectDefinitionBuilder {

	
	private static const log:Logger = LogContext.getLogger(XmlObjectDefinitionBuilder);
	
	
	private var mapper:XmlObjectMapper;
	private var _loader:XmlObjectDefinitionLoader;
	private var loadedFiles:Array;
	private var expressionContext:ExpressionContext;
	private var registry:ObjectDefinitionRegistry;

	
	function XmlObjectDefinitionBuilder (files:Array, expressionContext:ExpressionContext, loader:XmlObjectDefinitionLoader = null) {
		this.expressionContext = expressionContext;
		this._loader = (loader == null) ? new XmlObjectDefinitionLoader(files, expressionContext) : loader;
		var mapperFactory:XmlObjectDefinitionMapperFactory = new XmlObjectDefinitionMapperFactory();
		mapper = mapperFactory.createObjectDefinitionMapper();
	}

	
	public function get loader () : XmlObjectDefinitionLoader {
		return _loader;
	}
	
	public function addXml (xml:XML) : void {
		loadedFiles.push(new XmlFile("<local XML reference>", xml));
	}
	
	public function build (registry:ObjectDefinitionRegistry) : void {
		_loader.addEventListener(Event.COMPLETE, loaderComplete);
		_loader.addEventListener(ErrorEvent.ERROR, loaderError);
		_loader.load(registry.domain);
	}
	
	private function loaderComplete (event:Event) : void {
		loadedFiles = loadedFiles.concat(_loader.loadedFiles);
		var containerErrors:Array = new Array();
		for each (var file:XmlFile in loadedFiles) {
			try {
				var context:XmlProcessorContext = new XmlProcessorContext(expressionContext, registry.domain);
				var factoryErrors:Array = new Array();
				var container:ObjectDefinitionFactoryContainer 
						= mapper.mapToObject(file.rootElement, context) as ObjectDefinitionFactoryContainer;
				if (!context.hasErrors()) {
					for each (var obj:Object in container.objects) {
						try {
							var factory:ObjectDefinitionFactory;
							if (obj is ObjectDefinitionFactory) {
								factory = obj as ObjectDefinitionFactory;
							}
							else {
								var ci:ClassInfo = ClassInfo.forInstance(obj, registry.domain);
								var prop:Property = ci.getProperty("id");
								var id:String = (prop == null) ? null : prop.getValue(obj);
								factory	= new DefaultObjectDefinitionFactory(ci.getClass(), id);
							}
							var definition:RootObjectDefinition = factory.createRootDefinition(registry);
							registry.registerDefinition(definition);
							if (!(obj is ObjectDefinitionFactory)) {
								definition.instantiator = new ObjectWrapperInstantiator(obj);
							}
						} 
						catch (error:Error) {
							var msg:String = "Error building object definition with " + factory;
							log.error(msg + "{0}", e);
							factoryErrors.push(msg + ": " + e.message);		
						}
					}
				}	
				else {
					for each (var xmlError:Error in context.errors) {
						factoryErrors.push(xmlError.message);
					}
				}
				if (factoryErrors.length > 0) {
					containerErrors.push("One or more errors processing file " + file 
								+ ":\n " + factoryErrors.join("\n "));
				}
			}
			catch (e:Error) {
				var message:String = "Error processing file " + file;
				log.error(message + "{0}", e);
				containerErrors.push(message + ":\n " + e.message);
			}
		}
		if (containerErrors.length > 0) {
			var eventText:String = "One or more errors in XmlObjectDefinitionBuilder:\n " 
					+ containerErrors.join("\n ");	
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, eventText));
		}
		else {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	private function loaderError (event:ErrorEvent) : void {
		dispatchEvent(event.clone());
	}
	
	public function cancel () : void {
		_loader.cancel();
	}
}
}

import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.ObjectInstantiator;

class ObjectWrapperInstantiator implements ObjectInstantiator {

	private var instance:Object;
	
	function ObjectWrapperInstantiator (instance:Object) { this.instance = instance; }

	public function instantiate (context:Context) : Object {
		return instance;
	}
	
}
