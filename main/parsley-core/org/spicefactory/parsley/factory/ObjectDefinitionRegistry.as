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
 * @author Jens Halm
 */
public interface ObjectDefinitionRegistry {
	
	
	
	function get domain () : ApplicationDomain;

	
	function getDefinitionCount (type:Class = null) : uint;

	function getDefinitionIds (type:Class = null) : Array;

	
	function containsDefinition (id:String) : Boolean;

	function getDefinition (id:String) : RootObjectDefinition;
	

	function getAllDefinitionsByType (type:Class) : Array;

	function getDefinitionByType (type:Class, required:Boolean = false) : RootObjectDefinition;


	function registerDefinition (definition:RootObjectDefinition) : void;	
	
	function unregisterDefinition (definition:RootObjectDefinition) : void;
	
	
	function freeze () : void;
	
	function get frozen () : Boolean;
	
	
}

}
