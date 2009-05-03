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
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinition;
import org.spicefactory.parsley.util.IdGenerator;

/**
 * @author Jens Halm
 */
public class DefaultRootObjectDefinition extends DefaultObjectDefinition implements RootObjectDefinition {


	private var _id:String;
	private var _lazy:Boolean;
	private var _singleton:Boolean;


	public function DefaultRootObjectDefinition (type:ClassInfo, id:String, 
			lazy:Boolean = false, singleton:Boolean = true) : void {
		super(type);
		_id = id;
		_lazy = lazy;
		_singleton = singleton;
	}
	
	
	public static function fromDefinition (definition:ObjectDefinition, id:String = null, 
			lazy:Boolean = true, singleton:Boolean = true) : DefaultRootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var def:DefaultRootObjectDefinition = new DefaultRootObjectDefinition(definition.type, id, lazy, singleton);
		def.populateFrom(definition);
		return def;
	} 

	
	public function get id () : String {
		return _id;
	}
	
	public function get lazy () : Boolean {
		return _lazy;
	}
	
	public function get singleton () : Boolean {
		return _singleton;
	}
	
	
}

}
