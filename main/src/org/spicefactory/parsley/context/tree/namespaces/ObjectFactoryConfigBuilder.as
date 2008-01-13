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
 
package org.spicefactory.parsley.context.tree.namespaces {

import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
	

/**
 * Interface to be implemented by all configuration classes that 
 * represent custom tags that
 * can be used in place of the builtin <code>&lt;object&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public interface ObjectFactoryConfigBuilder	{

	/**
	 * The local name of the tag this instance is reponsible for. 
	 */
	function get tagName () : String;
	
	/**
	 * Creates and returns a <code>RootObjectFactoryConfig</code> instance.
	 * 
	 * @return a <code>RootObjectFactoryConfig</code> instance
	 */
	function buildRootObjectFactoryConfig () : RootObjectFactoryConfig;

	/**
	 * Creates and returns a <code>NestedObjectFactoryConfig</code> instance.
	 * 
	 * @return a <code>NestedObjectFactoryConfig</code> instance
	 */	
	function buildNestedObjectFactoryConfig () : NestedObjectFactoryConfig;
		
}

}