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
 
package org.spicefactory.parsley.context.xml {
	
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.ApplicationContext;
	
/**
 * Configuration for a single child node type.
 * 
 * @author Jens Halm
 */
public interface ChildConfig {
	
	/**
	 * The local name of the child node.
	 */
	function get name () : String;
	
	/**
	 * Checks whether the specified count is valid for this node.
	 * 
	 * @param count the actual number of parsed child nodes
	 * @return true if the specified count is valid for this node
	 */
	function isValidCount (count:uint) : Boolean;
	
	/**
	 * Checks whether this node is expected to be the only child of its parent node.
	 * 
	 * @return true if this node is expected to be the only child of its parent node
	 */
	function isSingleton () : Boolean;
	
	/**
	 * Creates a new <code>ElementConfig</code> instance that processes this child node.
	 * 
	 * @param context the <code>ApplicationContext</code> under construction
	 * @param node the child node to be processed
	 * @return a new <code>ElementConfig</code> instance responsible for processing the child node
	 */
	function createChild (context:ApplicationContext, node:XML) : ElementConfig;	
	
}

}