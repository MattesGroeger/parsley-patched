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
 * A registry for view definitions. These can then be applied to views
 * that are dynamically wired to the Context. View definitions can be
 * created by MXML or XML configuration or any custom mechanism.
 * 
 * @author Jens Halm
 */
public interface ViewDefinitionRegistry {
	
	/**
	 * Registers a view definition with this registry.
	 * If the id parameter is omitted the view definition can still be matched to
	 * dynamically wired views by type.
	 * 
	 * @param viewDefinition the view definition to add
	 */
	function registerDefinition (viewDefinition:ViewDefinition) : void;

	/**
	 * Returns the definition matching the specified id and type of the configuration target.
	 * If no definition for the specified id exists or if the type does not match
	 * this method should return null and never throw an Error.
	 * 
	 * @param id the id of the view definition
	 * @param configTarget the target the definition should be applied to
	 * @return the matching view definition or null
	 */
	function getDefinitionById (id:String, configTarget:Object) : ViewDefinition;

	/**
	 * Returns the definition matching the type of the specified target instance.
	 * If no match is found this method should return null and not throw an Error.
	 * If more than one match is found this method should throw an Error (or may
	 * choose to attempt to look for a "closest match").
	 * 
	 * @param configTarget the target the definition should be applied to
	 * @return the matching view definition or null
	 */
	function getDefinitionByType (configTarget:Object) : ViewDefinition;
	
	/**
	 * Freezes this registry. After calling this method any attempt to modify this registry or any
	 * of the definitions it contains will lead to an Error.
	 */
	function freeze () : void;
	
	/**
	 * Indicates whether this registry has been frozen. When true any attempt to modify this registry or any
	 * of the definitions it contains will lead to an Error.
	 */	
	function get frozen () : Boolean;
	

}
}
