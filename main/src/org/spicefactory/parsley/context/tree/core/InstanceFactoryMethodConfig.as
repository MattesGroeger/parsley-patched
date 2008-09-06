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
 
package org.spicefactory.parsley.context.tree.core {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a factory method of an object in the <code>ApplicationContext</code> -
 * in XML configuration the <code>&lt;factory-method&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class InstanceFactoryMethodConfig  
		extends FactoryMethodConfig implements ApplicationContextAware {


	private var _context:ApplicationContext;
	
	private var _factory:String;
	
	
	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			addValueConfigs(ep);
			ep.addAttribute("factory", StringConverter.INSTANCE, true);
			ep.addAttribute("method", StringConverter.INSTANCE, true);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
		
	
	/**
	 * Creates a new instance.
	 */
	public function InstanceFactoryMethodConfig () {
		super();
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
	
	
	public function set factory (value:String) : void {
		_factory = value;
	}

	/**
	 * The name of the factory instance in the <code>ApplicationContext</code>.
	 */
	public function get factory () : String {
		if (_factory != null) {
			return _factory;
		} else {
			return getAttributeValue("factory");
		}
	}
	
	/**
	 * @private
	 */
	protected override function getFactory () : Object {
		var factoryInstance:Object = _context.getObject(factory);
		if (factoryInstance == null) {
			throw new ConfigurationError("Unable to resolve factory with id '" + factory + "'");
		}
		return factoryInstance;
	}
	
	
	
}

}