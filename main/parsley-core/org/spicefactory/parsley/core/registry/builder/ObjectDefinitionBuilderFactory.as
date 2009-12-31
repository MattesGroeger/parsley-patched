/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.core.registry.builder {

/**
 * A factory for builders that can be used to create ObjectDefinitions programmatically.
 * 
 * @author Jens Halm
 */
public interface ObjectDefinitionBuilderFactory {
	
	/**
	 * Returns a builder for a root definition for the specified type.
	 * 
	 * @param type the type to create a definition for
	 */
	function forRootDefinition (type:Class) : RootObjectDefinitionBuilder;
	
	/**
	 * Returns a builder for a nested definition for the specified type.
	 * 
	 * @param type the type to create a definition for
	 */
	function forNestedDefinition (type:Class) : NestedObjectDefinitionBuilder;

	/**
	 * Returns a builder for a view definition for the specified type.
	 * 
	 * @param type the type to create a definition for
	 */
	function forViewDefinition (type:Class) : ViewDefinitionBuilder;
	
}
}
