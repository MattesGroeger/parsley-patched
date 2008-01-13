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

/**
 * Represents the additional metadata of top level object configurations.
 * 
 * @author Jens Halm
 */
public class FactoryMetadata {
	
	private var _id:String;
	private var _singleton:Boolean;
	private var _lazy:Boolean;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param id the id of the object
	 * @param singleton whether this is a configuration for a singleton
	 * @param lazy whether this object should be instantiated the first time it is accessed or 
	 * immediately after <code>ApplicationContext</code> initialization
	 */
	function FactoryMetadata (id:String, singleton:Boolean, lazy:Boolean) {
		_id = id;
		_singleton = singleton;
		_lazy = lazy;
	}
	
	
	public function set id (param:String) : void {
		_id = param;
	}
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#id
	 */
	public function get id () : String {
		return _id;
	}
	
	public function set singleton (param:Boolean) : void {
		_singleton = param;
	}
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#singleton.
	 */
	public function get singleton () : Boolean {
		return _singleton;
	}
	
	public function set lazy (param:Boolean) : void {
		_lazy = param;
	}
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#lazy
	 */
	public function get lazy () : Boolean {
		return _lazy;
	}	
	
}

}