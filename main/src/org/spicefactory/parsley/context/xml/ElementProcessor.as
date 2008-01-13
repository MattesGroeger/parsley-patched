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

import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AttributeContainer;
	
/**
 * Interface to be implemented by object that parse and process a single node of an XML object.
 * In most cases it is expected that implementations of this interface delegate parsing of
 * any child nodes to nested <code>ElementProcessor</code> instances.
 * 
 * @author Jens Halm
 */
public interface ElementProcessor {
	
	/**
	 * Parses the specified node, populating the specified <code>AttributeContainer</code>.
	 * 
	 * @param node the node to parse
	 * @param config the container to populate
	 * @param context the <code>ApplicationContext</code> under construction
	 */
	function parse (node:XML, config:AttributeContainer, context:ApplicationContext) : void;
	
}

}