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

package org.spicefactory.parsley.xml.processor {
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.expr.impl.DefaultExpressionContext;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.parsley.core.builder.AsyncConfigurationProcessor;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.tag.RootConfigurationTag;
import org.spicefactory.parsley.xml.mapper.XmlObjectDefinitionMapperFactory;
import org.spicefactory.parsley.xml.tag.ObjectsTag;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * ObjectDefinitionBuilder implementation that processes XML configuration files.
 * This builder operates asynchronously.
 * 
 * @author Jens Halm
 */
public class XmlConfigurationProcessor extends EventDispatcher implements AsyncConfigurationProcessor {

	
	private static const log:Logger = LogContext.getLogger(XmlConfigurationProcessor);
	
	
	private var mapper:XmlObjectMapper;
	private var _loader:XmlConfigurationLoader;
	private var loadedFiles:Array = new Array();
	private var expressionContext:ExpressionContext;
	private var registry:ObjectDefinitionRegistry;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param files the names of the XML configuration files
	 */
	function XmlConfigurationProcessor (files:Array, expressionContext:ExpressionContext = null, loader:XmlConfigurationLoader = null) {
		if (expressionContext == null) expressionContext = new DefaultExpressionContext();
		this.expressionContext = expressionContext;
		this._loader = (loader == null) ? new XmlConfigurationLoader(files, expressionContext) : loader;
		var mapperFactory:XmlObjectDefinitionMapperFactory = new XmlObjectDefinitionMapperFactory();
		mapper = mapperFactory.createObjectDefinitionMapper();
	}

	
	/**
	 * The loader that loads the XML configuration files.
	 */	
	public function get loader () : XmlConfigurationLoader {
		return _loader;
	}
	
	/**
	 * Adds an XML reference containing Parsley XML configuration to be processed alongside the loaded files.
	 * 
	 * @param xml an XML reference containing Parsley XML configuration
	 */
	public function addXml (xml:XML) : void {
		loadedFiles.push(new XmlFile("<local XML reference>", xml));
	}
	
	/**
	 * @inheritDoc
	 */
	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		this.registry = registry;
		_loader.addEventListener(Event.COMPLETE, loaderComplete);
		_loader.addEventListener(ErrorEvent.ERROR, loaderError);
		_loader.load(registry.domain);
	}

	private function loaderComplete (event:Event) : void {
		loadedFiles = loadedFiles.concat(_loader.loadedFiles);
		processAllFiles(loadedFiles);
	}
	
	private function processAllFiles (files:Array) : void {
		var containerErrors:Array = new Array();
		for each (var file:XmlFile in files) {
			try {
				processFile(file, containerErrors);
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
	
	private function processFile (file:XmlFile, containerErrors:Array) : void {
		var context:XmlProcessorContext = new XmlProcessorContext(expressionContext, registry.domain);
		var factoryErrors:Array = new Array();
		var container:ObjectsTag 
				= mapper.mapToObject(file.rootElement, context) as ObjectsTag;
		if (!context.hasErrors()) {
			for each (var obj:Object in container.objects) {
				try {
					processObject(obj);
				} 
				catch (error:Error) {
					var msg:String = "Error building object definition for " + obj;
					log.error(msg + "{0}", error);
					factoryErrors.push(msg + ": " + error.message);		
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
	
	private function processObject (obj:Object) : void {
		if (obj is ObjectDefinitionFactory) {
			/* TODO - ObjectDefinitionFactory is deprecated - remove in later versions */
			var definition:RootObjectDefinition = ObjectDefinitionFactory(obj).createRootDefinition(registry);
			registry.registerDefinition(definition);
		}
		else if (obj is RootConfigurationTag) {
			RootConfigurationTag(obj).process(registry);
		}
		else {
			var ci:ClassInfo = ClassInfo.forInstance(obj, registry.domain);
			var idProp:Property = ci.getProperty("id");
			registry.builders
					.forRootDefinition(ci.getClass())
					.id((idProp == null) ? null : idProp.getValue(obj))
					.instantiator(new ObjectWrapperInstantiator(obj))
					.buildAndRegister();
		}
	}


	private function loaderError (event:ErrorEvent) : void {
		dispatchEvent(event.clone());
	}
	
	/**
	 * @inheritDoc
	 */
	public function cancel () : void {
		_loader.cancel();
	}
}
}

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.definition.ContainerObjectInstantiator;

class ObjectWrapperInstantiator implements ContainerObjectInstantiator {

	private var instance:Object;
	
	function ObjectWrapperInstantiator (instance:Object) { this.instance = instance; }

	public function instantiate (context:Context) : Object {
		return instance;
	}
	
}
