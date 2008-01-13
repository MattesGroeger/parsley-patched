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
 
package org.spicefactory.parsley.context.xml {
import org.spicefactory.lib.util.ClassUtil;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.factory.ElementConfig;

/**
 * Default implementation of the <code>ChildConfig</code> interface.
 * 
 * @author Jens Halm
 */
public class DefaultChildConfig	implements ChildConfig {
	
	
	private var _name:String;
	private var _ChildClass:Class;
	private var _constructorArgs:Array;
	private var _minOccurs:uint;
	private var _maxOccurs:uint;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param name the local name of the child node
	 * @param ChildClass the class of the configuration object processing the child node
	 * @param constructorArgs the parameters to be passed to the constructor of the configuration object
	 * @param minOccurs the minimum number of required occurrences of that child node
	 * @param maxOccurs the maximum number of allowed occurrences of that child node
	 */
	function DefaultChildConfig (name:String, ChildClass:Class, constructorArgs:Array, 
			minOccurs:uint, maxOccurs:uint = 0) {
		_name = name;
		_ChildClass = ChildClass;
		_constructorArgs = constructorArgs;
		_minOccurs = minOccurs;
		_maxOccurs = maxOccurs;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get name () : String {
		return _name;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isValidCount (count:uint) : Boolean {
		return (count >= _minOccurs && (_maxOccurs == 0 || count <= _maxOccurs));
	}
	
	/**
	 * @inheritDoc
	 */
	public function isSingleton () : Boolean {
		return (_maxOccurs == 1);
	}
	
	/**
	 * @inheritDoc
	 */
	public function createChild (context:ApplicationContext, node:XML) : ElementConfig {
		return ElementConfig(ClassUtil.createNewInstance(_ChildClass, _constructorArgs));
	}
	
	
}

}