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
 
package org.spicefactory.parsley.context.tree.namespaces.template {
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.DefaultObjectFactoryConfig;
import org.spicefactory.parsley.context.ApplicationContext;
	

/**
 * Wraps an <code>ObjectFactoryConfig</code> instance to adapt it to the <code>ElementConfig</code>
 * interface needed for parsing the template.
 * 
 * @author Jens Halm
 */
public class ObjectFactoryConfigWrapper	implements ElementConfig {

	
	private var _delegate:ObjectFactoryConfig;
	
	/**
	 * Creates a new instance.
	 */
	public function ObjectFactoryConfigWrapper () {
		_delegate = new DefaultObjectFactoryConfig();
	}
	
	/**
	 * @inheritDoc
	 */
	public function parse (node : XML, context : ApplicationContext) : void {
		_delegate.parseNestedObject(node, context);
	}
	
	/**
	 * Returns the wrapped <code>ObjectFactoryConfig</code> instance.
	 * 
	 * @return the wrapped <code>ObjectFactoryConfig</code> instance
	 */
	public function getObjectFactoryConfig () : ObjectFactoryConfig {
		return _delegate;
	}
	
	
	
}

}