/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.factory {
import flash.system.ApplicationDomain;

/**
 * A registry for object definitions.
 * 
 * <p>All builtin <code>Context</code> implementations use such a registry internally.</p>
 * 
 * @author Jens Halm
 */
public interface ObjectDefinitionRegistry {
	
	
	/**
	 * The ApplicationDomain to use for reflection.
	 */
	function get domain () : ApplicationDomain;

	
	/**
	 * Returns the number of definitions in this registry that match the specified type.
	 * If the type parameter is omitted the number of all definitions in this registry will be returned.
	 * 
	 * @param type the type to check for matches
	 * @return the number of definitions in this registry that match the specified type
	 */
	function getDefinitionCount (type:Class = null) : uint;

	/**
	 * Returns the ids of the definitions in this registry that match the specified type.
	 * If the type parameter is omitted the ids of all definitions in this registry will be returned.
	 * 
	 * @param type the type to check for matches
	 * @return the ids of the definitions in this registry that match the specified type
	 */
	function getDefinitionIds (type:Class = null) : Array;

	
	/**
	 * Checks whether this registry contains an definition with the specified id.
	 * 
	 * @param id the id to check
	 * @return true if this registry contains an definition with the specified id  
	 */
	function containsDefinition (id:String) : Boolean;

	/**
	 * Returns the definition with the specified id. Throws an Error if no such definition exists.
	 * 
	 * @param id the id of the definition
	 * @return the definition with the specified id
	 */
	function getDefinition (id:String) : RootObjectDefinition;
	

	/**
	 * Returns the defintion for the specified type. If the <code>required</code> parameter is set to true
	 * this method will throw an Error if no defintion with a matching type exists in this registry.
	 * In either case it will throw an Error if it finds more than one match.
	 * 
	 * @param type the type for which the defintion should be returned
	 * @param required whether a match is required
	 * @return the definition for the specified type
	 */
	function getDefinitionByType (type:Class, required:Boolean = false) : RootObjectDefinition;

	/**
	 * Returns all defintions that match the specified type. This includes subclasses or objects implementing
	 * the interface in case the type parmeter is an interface. When no match is found an empty Array will be returned.
	 * 
	 * @param type the type for which all defintions should be returned
	 * @return all defintions that match the specified type
	 */
	function getAllDefinitionsByType (type:Class) : Array;


	/**
	 * Registers an object definition with this registry.
	 * 
	 * @param definition the definition to add to this registry
	 */
	function registerDefinition (definition:RootObjectDefinition) : void;	
	
	/**
	 * Unregisters an object definition from this registry.
	 *
  	 * @param definition the definition to remove from this registry
	 */
	function unregisterDefinition (definition:RootObjectDefinition) : void;
	
	
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
