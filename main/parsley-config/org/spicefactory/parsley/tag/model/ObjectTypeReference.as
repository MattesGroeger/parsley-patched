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

package org.spicefactory.parsley.tag.model {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ResolvableValue;

/**
 * Represent a reference to an object in the Parsley Context by type.
 * 
 * @author Jens Halm
 */
public class ObjectTypeReference implements ResolvableValue {


	private var _type:ClassInfo;
	private var _required:Boolean;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of the referenced object
	 * @param required whether this instance represents a required dependency
	 */	
	function ObjectTypeReference (type:ClassInfo, required:Boolean = true) {
		_type = type;
		_required = required;
	}

	/**
	 * Indicates whether this instance represents a required dependency.
	 */
	public function get required () : Boolean {
		return _required;
	}

	/**
	 * The type of the referenced object.
	 */
	public function get type () : ClassInfo {
		return _type;
	}
	
	public function resolve (target:ManagedObject) : * {
		if (type.isType(Context)) {
			return target.context;
		}
		var ids:Array = target.context.getObjectIds(type.getClass());
		if (ids.length > 1) {
			throw new ContextError("Ambigous dependency: Context contains more than one object of type "
					+ type.name);
		} 
		else if (ids.length == 0) {
			if (required) {
				throw new ContextError("Unsatisfied dependency: Context does not contain an object of type " 
					+ type.name);
			}
			else {
				return null;
			}				
		}
		else {
			return target.resolveObjectReference(ids[0]);
		}
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "{Injection(type=" + type.name + ")}";
	}	
	
	
}

}
