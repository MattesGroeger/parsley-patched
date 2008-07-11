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
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.factory.ParserContext;
import org.spicefactory.parsley.context.tree.AbstractAttributeContainer;

/**
 * Implementation of <code>NestedObjectFactoryConfig</code> that delegates 
 * to an <code>ObjectFactoryConfig</code>.
 * 
 * @author Jens Halm
 */
public class DelegatingNestedObjectFactoryConfig 
		extends AbstractAttributeContainer implements NestedObjectFactoryConfig {
	

	private var _delegate:ObjectFactoryConfig;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param Type the class of the <code>ObjectFactoryConfig</code> to delegate to
	 */	
	function DelegatingNestedObjectFactoryConfig (Type:Class = null) {
		if (Type != null) _delegate = new Type();
	}

	/**
	 * Creates a new <code>DelegatingNestedObjectFactory</code> using the
	 * specified <code>ObjectFactoryConfig</code> as the delegate.
	 * 
	 * @param config the <code>ObjectFactoryConfig</code> instance to use as the delegate
	 */	
	public static function forFactoryConfig (config:ObjectFactoryConfig) : DelegatingNestedObjectFactoryConfig {
		var del:DelegatingNestedObjectFactoryConfig = new DelegatingNestedObjectFactoryConfig();
		del._delegate = config;
		return del;
	}
	
	/**
	 * @inheritDoc
	 */
	public function parse (node : XML, context : ApplicationContext) : void {
		ParserContext.pushParserContext(this);
		try {
			_delegate.parseNestedObject(node, context);
		} finally {
			ParserContext.popParserContext();
		}
	}

	/**
	 * @inheritDoc
	 */	
	public function get value() : * {
		return _delegate.createObject();
	}
	
	
	
}

}