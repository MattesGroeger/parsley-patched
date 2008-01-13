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
 
package org.spicefactory.parsley.context.tree.core {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.context.factory.ElementConfig;

/**
 * Represents a configuration for a top level object in an <code>ApplicationContext</code>.
 * These top level objects can be obtained by several methods of the <code>ApplicationContext</code>
 * class like <code>getObject(id:String)</code> and in contrast 
 * to configuration for nested objects it needs additional properties like
 * <code>singleton</code> or <code>lazy</code>.
 * 
 * @author Jens Halm
 */
public interface RootObjectFactoryConfig extends ElementConfig {
	
	/**
	 * The id of the object.
	 */
	function get id () : String;
	
	/**
	 * The class of the object.
	 */
	function get type () : ClassInfo;
	
	/**
	 * Indicates whether this object is a singleton.
	 */
	function get singleton () : Boolean;
	
	/**
	 * Indicates whether this object will be instantiated when the <code>ApplicationContext</code>
	 * is initialized (<code>lazy = false</code>) or if it will be instantiated when 
	 * it is accessed for the first time by application (<code>lazy = true</code>).
	 * Has no effect when the <code>singleton</code> property is set to <code>false</code>. 
	 */
	function get lazy () : Boolean;
	
	/**
	 * Creates, configures and returns the object.
	 * 
	 * @param a new instance after all configuration has been applied
	 */
	function createObject () : Object;
	
	
}

}