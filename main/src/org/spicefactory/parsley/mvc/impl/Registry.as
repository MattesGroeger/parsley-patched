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
 
package org.spicefactory.parsley.mvc.impl {
import org.spicefactory.lib.util.ArrayUtil;

import flash.utils.Dictionary;

/**
 * Registry that maps key to array of items.
 * 
 * @author Jens Halm
 */
public class Registry {
	
	
	private var dictionary:Dictionary = new Dictionary();
	
	
	/**
	 * Adds the specified item to the list of items (if any) that are already registered for that key.
	 * 
	 * @param key the key the list of registered items is mapped to
	 * @param item the item to add to the list of registered items
	 */
	public function registerItem (key:String, item:Object) : void {
		var items:Array = dictionary[key];
		if (items == null) {
			items = new Array();
			dictionary[key] = items;
		}
		items.push(item);
	}

	/**
	 * Removes the specified item from the list of items that are registered for that key.
	 * 
	 * @param key the key the list of registered items is mapped to
	 * @param item the item to remove from the list of registered items
	 */	
	public function unregisterItem (key:String, item:Object) : void {
		var items:Array = dictionary[key];
		if (items != null) {
			removeItem(items, item);
			if (items.length == 0) {
				delete dictionary[key];
			}
		}
	}
	
	protected function removeItem (items:Array, item:Object) : void {
		ArrayUtil.remove(items, item);
	}
	
	/**
	 * Returns all registered items for the specified key.
	 * 
	 * @param key the key to return all registered items for
	 * @return all registered items for the specified key
	 */
	public function getItems (key:String) : Array {
		var items:Array = dictionary[key];
		return (items == null) ? [] : items;
	}
	
	
}

}
