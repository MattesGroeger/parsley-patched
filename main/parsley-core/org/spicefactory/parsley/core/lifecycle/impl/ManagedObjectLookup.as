/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.core.lifecycle.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import flash.utils.Dictionary;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;

/**
 * Utility class that allows lookup of ManagedObject instances.
 * 
 * @author Jens Halm
 */
public class ManagedObjectLookup {
	
	
	private static const map:Dictionary = new Dictionary();
	
	
	/**
	 * Returns the ManagedObject instance that holds the specified object or null if the
	 * object is not managed by any Context currently.
	 * 
	 * @param instance the object to return the corresponding ManagedObject instance for
	 * @return the ManagedObject instance that holds the specified object
	 */
	public static function forInstance (instance:Object) : ManagedObject {
		return map[instance] as ManagedObject;
	}
	
	/**
	 * @private
	 */
	internal static function addManagedObject (mo:ManagedObject) : void {
		if (map[mo.instance]) {
			throw new IllegalArgumentError("Object of type " + mo.definition.type.name + " is already managed");	
		}
		map[mo.instance] = mo;
	}
	
	/**
	 * @private
	 */
	internal static function removeManagedObject (mo:ManagedObject) : void {
		delete map[mo.instance];
	}
	
	
}
}
