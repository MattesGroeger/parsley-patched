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
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;
import org.spicefactory.parsley.factory.registry.LifecycleListenerRegistry;

/**
 * @author Jens Halm
 */
public class DefaultLifecycleListenerRegistry extends AbstractRegistry implements LifecycleListenerRegistry {


	private var listeners:Array = new Array();


	function DefaultLifecycleListenerRegistry (def:ObjectDefinition) {
		super(def);
	}

	
	public function addLifecycleListener (listener:ObjectLifecycleListener,
			priority:int = 0) : LifecycleListenerRegistry {
		checkState();
		listeners.push(new LifecycleListenerRegistration(listener, priority));
		return this;
	}
	
	public function removeLifecycleListener (listener:ObjectLifecycleListener) : LifecycleListenerRegistry {
		checkState();
		for (var i:uint = 0; i < listeners.length; i++) {
			var reg:LifecycleListenerRegistration = LifecycleListenerRegistration(listeners[i]);
			if (reg.listener == listener) {
				listeners.slice(i,1);
			}
		}
		return this;
	}
	
	public function getAll () : Array {
		listeners.sortOn("priority", Array.NUMERIC | Array.DESCENDING);
		var result:Array = new Array();
		for each (var reg:LifecycleListenerRegistration in listeners) {
			result.push(reg.listener);
		}
		return result;
	}
	
	
}
}

import org.spicefactory.parsley.factory.ObjectLifecycleListener;

class LifecycleListenerRegistration {
	public var priority:int;
	public var listener:ObjectLifecycleListener;
	function LifecycleListenerRegistration (listener:ObjectLifecycleListener, priority:int) {
		this.priority = priority;
		this.listener = listener;
	}
}