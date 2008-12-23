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

package org.spicefactory.parsley.factory.registry.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.FunctionBase;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.model.ObjectIdReference;
import org.spicefactory.parsley.factory.model.ObjectTypeReference;

/**
 * @author Jens Halm
 */
public class AbstractParameterRegistry extends AbstractRegistry {
	
	
	private var args:Array = new Array();
	private var func:FunctionBase;


	function AbstractParameterRegistry (func:FunctionBase, def:ObjectDefinition) {
		super(def);
		this.func = func;
	}
		
	
	protected function doAddValue (value:*) : void {
		checkState();
		args.push(value);
	}
	
	protected function doAddIdReference (id:String, required:Boolean = true) : void {
		checkState();
		args.push(new ObjectIdReference(id, required));		
	}
	
	protected function doAddTypeReference (required:Boolean = true) : void {
		checkState();
		if (args.length >= func.parameters.length) {
			throw new IllegalArgumentError("Cannot determine target type for parameter at index"
					+ args.length + " of constructor for class " + func.owner.name);
		}
		var type:ClassInfo = Parameter(func.parameters[args.length]).type;
		args.push(new ObjectTypeReference(type, required));	
	}
	
	protected function getAt (index:uint) : * {
		return args[index];	
	}
	
	public function getAll () : Array {
		return args.concat();
	}
	
	
}
}
