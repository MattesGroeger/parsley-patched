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
 
package org.spicefactory.parsley.context.factory {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.context.ApplicationContext;

/**
 * Interface to be implemented by all classes that process XML nodes that act
 * as a factory that creates new instances. An example for such a node is the
 * builtin <code>&lt;object&gt;</code> tag but also any tag from a custom configuration
 * namespace that is responsible for acting as a factory.
 * 
 * @author Jens Halm
 */
public interface ObjectFactoryConfig {
	
	/**
	 * The type of object this factory produces.
	 */
	function get type () : ClassInfo;
	
	/**
	 * Parses the specified XML node as a root object configuration.
	 * Root objects are those that are defined as direct children of the <code>factory</code>
	 * tag and that can be obtained by the <code>ApplicationContext</code> either by id or by type.
	 * 
	 * @param node the XML node to parse
	 * @param context the ApplicationContext this factory belongs to
	 * @return the metadata required to define a root object
	 */
	function parseRootObject (node:XML, context:ApplicationContext) : FactoryMetadata;
	
	/**
	 * Parses the specified XML node as a nested object configuration.
	 * Nested objects are those that are defined nested in other object configurations
	 * and that are not directly accessible through the <code>ApplicationContext</code>.
	 * 
	 * @param node the XML node to parse
	 * @param context the ApplicationContext this factory belongs to 
	 */
	function parseNestedObject (node:XML, context:ApplicationContext) : void;
	
	/**
	 * Creates, configures and returns a new instance.
	 * 
	 * @return a fully configured new instance
	 */
	function createObject () : Object;

}

}