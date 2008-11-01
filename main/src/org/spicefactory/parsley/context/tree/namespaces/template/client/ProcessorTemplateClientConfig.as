/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.tree.namespaces.template.client {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractAttributeContainer;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.tree.namespaces.template.context.TemplateProcessorContext;

/**
 * Represents a client node of a template used in the context of an object processor.
 * 
 * @author Jens Halm
 */
public class ProcessorTemplateClientConfig  
		extends AbstractAttributeContainer implements ObjectProcessorConfig, ApplicationContextAware {
	
	
	private var _context:ApplicationContext;
	private var objectProcessorConfig:ObjectProcessorConfig;
	private var childProcessor:ElementConfig;
	
	private var attributes:Object;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param opc the object processor for this template client
	 * @param childProcessor the optional element configuration for child nodes
	 */	
	function ProcessorTemplateClientConfig (opc:ObjectProcessorConfig, childProcessor:ElementConfig) {
		objectProcessorConfig = opc;
		this.childProcessor = childProcessor;
	}
	
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function parse (node : XML, context : ApplicationContext) : void {
		_context = context; // TODO - 1.0.3 - should be obsolete with ApplicationContextAware
		attributes = new Dictionary();
		var attr:XMLList = node.attributes();
		for each (var at:XML in attr) {
			attributes[at.localName()] = at.toXMLString();
		}
		if (childProcessor != null) {
			childProcessor.parse(node, context);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		TemplateProcessorContext.pushTemplateContext(_context, childProcessor, attributes);
		objectProcessorConfig.process(obj, ci, destroyCommands);
		TemplateProcessorContext.popTemplateContext();		
	}



}

}