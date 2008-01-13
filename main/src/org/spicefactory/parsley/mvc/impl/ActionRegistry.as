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
import org.spicefactory.parsley.mvc.impl.Registry;

/**
 * Special subclass of <code>Registry</code> that works with <code>ActionRegistration</code>
 * instances and uses their <code>equals</code> methods for finding items to remove.
 * 
 * @author Jens Halm
 */
public class ActionRegistry extends Registry {


	/**
	 * Creates a new instance.
	 */
	public function ActionRegistry () {
		super();
	}
	
	/**
	 * @inheritDoc
	 */
	protected override function removeItem (items:Array, item:Object) : void {
		var remove : ActionRegistration = findRegistration(items, item as ActionRegistration);
		if (remove != null) {
			ArrayUtil.remove(items, remove);
		}
	}
	
	private function findRegistration (items:Array, registration:ActionRegistration) 
			: ActionRegistration {
		for each (var action:ActionRegistration in items) {
			if (registration.equals(action)) {
				return action;
			}
		}
		return null;
	}
	
	
}

}

