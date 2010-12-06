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

package org.spicefactory.parsley.core.scope {
	


/**
 * A registry for scope-wide extensions.
 * Usually used for registering manager-type objects that may be used by custom configuration tags.
 * 
 * @author Jens Halm
 */
public interface ScopeExtensionRegistry {
	
	
	/**
	 * Adds a scope extension to this registry.
	 * If the scope parameter is omitted, a new extension instance will be created for each new scope that
	 * this registry is responsible for.
	 * 
	 * @param type the type of the extension
	 * @param params the parameters to pass to the constructor of the extension
	 * @param scope the scope the extension is responsible for
	 * @param id an optional id the extension should be registered with
	 */
	function addExtension (type:Class, params:Array = null, scope:String = null, id:String = null) : void;
	
	/**
	 * Returns all extensions for the specified scope.
	 * 
	 * @param scope the scope to return all extensions for
	 * @return all extensions for the specified scope
	 */
	function getExtensions (scope:String) : ScopeExtensions;
	
	
}
}
