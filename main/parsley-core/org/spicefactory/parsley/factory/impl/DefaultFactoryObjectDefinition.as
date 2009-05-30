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

package org.spicefactory.parsley.factory.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.factory.FactoryObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

/**
 * Default implementation of the FactoryObjectDefintion interface.
 * 
 * @author Jens Halm
 */
public class DefaultFactoryObjectDefinition extends DefaultRootObjectDefinition implements FactoryObjectDefinition {
	
	
	private var _targetDefinition:ObjectDefinition;
	
	
	/**
	 * Creates a new instance
	 * 
	 * @param target the definition the object described by this factory definiton creates
	 * 
	 */
	function DefaultFactoryObjectDefinition (target:ObjectDefinition, type:ClassInfo, id:String, 
			lazy:Boolean = true, singleton:Boolean = true) {
		super(type, id, lazy, singleton);
		_targetDefinition = target;
	}


	/**
	 * Creates a new factory definition from the specified definitions for the target object and the factory itself.
	 * 
	 * @param factoryDefinition the definition for the factory object
	 * @param targetDefinition the definition for the target object (the object created by the factory object)
	 * @param id the id the object should be registered with
	 * @param lazy whether the object is lazy initializing
	 * @param singleton whether the object should be treated as a singleton
	 */
	public static function fromDefinition (factoryDefinition:ObjectDefinition, targetDefinition:ObjectDefinition, 
			id:String = null, lazy:Boolean = true, singleton:Boolean = true) : DefaultFactoryObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var def:DefaultFactoryObjectDefinition 
				= new DefaultFactoryObjectDefinition(targetDefinition, factoryDefinition.type, id, lazy, singleton);
		def.populateFrom(factoryDefinition);
		return def;
	} 
	
	
	/**
	 * @inheritDoc
	 */
	public function get targetDefinition () : ObjectDefinition {
		return _targetDefinition;
	}	
	
	
}

}
