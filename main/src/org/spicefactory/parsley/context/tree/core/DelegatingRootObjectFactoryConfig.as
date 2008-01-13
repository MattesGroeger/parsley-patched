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
import org.spicefactory.parsley.context.factory.ParserContext;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.factory.FactoryMetadata;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.AbstractAttributeContainer;

/**
 * Implementation of <code>RootObjectFactoryConfig</code> that delegates 
 * to an <code>ObjectFactoryConfig</code>.
 * 
 * @author Jens Halm
 */
public class DelegatingRootObjectFactoryConfig  
		extends AbstractAttributeContainer implements RootObjectFactoryConfig {
			
	
	private var _delegate:ObjectFactoryConfig;
	private var _metaData:FactoryMetadata;
	
	private var _instance:Object;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param Type the class of the <code>ObjectFactoryConfig</code> to delegate to
	 */
	function DelegatingRootObjectFactoryConfig (Type:Class = null) {
		if (Type != null) _delegate = new Type();
	}
	
	/**
	 * Creates a new <code>DelegatingRootObjectFactory</code> using the
	 * specified <code>ObjectFactoryConfig</code> as the delegate.
	 * 
	 * @param config the <code>ObjectFactoryConfig</code> instance to use as the delegate
	 */
	public static function forFactoryConfig (config:ObjectFactoryConfig) : DelegatingRootObjectFactoryConfig {
		var del:DelegatingRootObjectFactoryConfig = new DelegatingRootObjectFactoryConfig();
		del._delegate = config;
		return del;
	}
	
	/**
	 * @inheritDoc
	 */
	public function parse (node : XML, context : ApplicationContext) : void {
		ParserContext.pushParserContext(this);
		try {
			_metaData = _delegate.parseRootObject(node, context);
		} finally {
			ParserContext.popTemplateContext();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		return _metaData.id;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return _delegate.type;
	}

	/**
	 * @inheritDoc
	 */
	public function get singleton () : Boolean {
		return _metaData.singleton;
	}

	/**
	 * @inheritDoc
	 */
	public function get lazy () : Boolean {
		return _metaData.lazy;
	}

	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {
		// return existing instance if possible
		if (_metaData.singleton && _instance != null) {
			return _instance;
		}
		
		var obj:Object = _delegate.createObject();
		
		// save instance if necessary	
		if (_metaData.singleton) {
			_instance = obj;
		}
		
		return obj;
	}
	
	
	
}

}