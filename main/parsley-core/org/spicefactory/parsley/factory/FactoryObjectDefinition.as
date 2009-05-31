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

/**
 * Object definition for factories. Such a definition is always associated with a second definition representing
 * the object type the factory produces.
 * 
 * @author Jens Halm
 */
public interface FactoryObjectDefinition extends RootObjectDefinition {
	
	
	/**
	 * The definition representing
 	 * the target object type that the factory represented by this definition produces.
	 */
	function get targetDefinition () : ObjectDefinition;
	
	
}

}
