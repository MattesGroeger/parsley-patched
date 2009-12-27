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

package org.spicefactory.parsley.core.registry {

/**
 * Interface that can be used by the various configuration mechanisms to create tags
 * that produce view definitions.
 * 
 * @author Jens Halm
 */
public interface ViewDefinitionFactory {
	
	/**
	 * The optional id the view definition produced by this factory should be registered with.
	 */
	function get configId () : String;
	
	/**
	 * Creates a view definition that can be applied to dynamically wired views.
	 * 
	 * @param registry the registry that the new definition will belong to
	 * @return a new view definition
	 */
	function createDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition;

}
}
