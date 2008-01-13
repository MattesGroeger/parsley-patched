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

import org.spicefactory.parsley.context.tree.AbstractAttributeContainer;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
	

/**
 * Abstract base implementation for factory template clients.
 * 
 * @author Jens Halm
 */
public class AbstractFactoryTemplateClientConfig  
		extends AbstractAttributeContainer implements ApplicationContextAware, ElementConfig {
	
	
	private var _context:ApplicationContext;
	
	/**
	 * The <code>ObjectFactoryConfig</code> to delegate to.
	 */
	protected var objectFactoryConfig:ObjectFactoryConfig;
	
	/**
	 * The class to use to process child nodes.
	 */
	protected var childProcessor:ElementConfig;
	
	/**
	 * The custom attributes for this tag.
	 */
	protected var attributes : Dictionary;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param ofc the object factory for this template client
	 * @param childProcessor the optional element configuration for child nodes
	 */
	function AbstractFactoryTemplateClientConfig (ofc:ObjectFactoryConfig, childProcessor:ElementConfig) {
		objectFactoryConfig = ofc;
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
		_context = context; // TODO - 1.1.0 - should be obsolete with ApplicationContextAware
		attributes = new Dictionary();
		var attr:XMLList = node.attributes();
		for each (var at:XML in attr) {
			attributes[at.localName()] = at.toXMLString();
		}
		if (childProcessor != null) {
			childProcessor.parse(node, context);
		}
	}



}

}