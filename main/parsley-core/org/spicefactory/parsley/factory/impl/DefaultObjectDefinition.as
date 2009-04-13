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
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectInstantiator;
import org.spicefactory.parsley.factory.registry.ConstructorArgRegistry;
import org.spicefactory.parsley.factory.registry.LifecycleListenerRegistry;
import org.spicefactory.parsley.factory.registry.MethodRegistry;
import org.spicefactory.parsley.factory.registry.PropertyRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultConstructorArgRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultLifecycleListenerRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultMethodRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultPropertyRegistry;

/**
 * @author Jens Halm
 */
public class DefaultObjectDefinition implements ObjectDefinition {

	
	private var _type:ClassInfo;
	
	private var _instantiator:ObjectInstantiator;
	private var _constructorArgs:ConstructorArgRegistry;
	private var _properties:PropertyRegistry;
	private var _methods:MethodRegistry;
	private var _listeners:LifecycleListenerRegistry;

	private var _frozen:Boolean;

	
	function DefaultObjectDefinition (type:ClassInfo) {
		_type = type;
		_constructorArgs = new DefaultConstructorArgRegistry(this);
		_properties = new DefaultPropertyRegistry(this);
		_methods = new DefaultMethodRegistry(this);
		_listeners = new DefaultLifecycleListenerRegistry(this);
	}


	public function populateFrom (definition:ObjectDefinition) : void {
		checkState();
		_instantiator = definition.instantiator;
		_constructorArgs = definition.constructorArgs;
		_properties = definition.properties;
		_methods = definition.injectorMethods;
		_listeners = definition.lifecycleListeners;
	}

	
	public function get type () : ClassInfo {
		return _type;
	}
	
	public function get constructorArgs () : ConstructorArgRegistry {
		return _constructorArgs;
	}

	public function get properties () : PropertyRegistry {
		return _properties;
	}

	public function get injectorMethods () : MethodRegistry {
		return _methods;
	}

	public function get lifecycleListeners () : LifecycleListenerRegistry {
		return _listeners;
	}
	
	public function get instantiator () : ObjectInstantiator {
		return _instantiator;
	}
	
	public function set instantiator (value:ObjectInstantiator) : void {
		checkState();
		_instantiator = value;
	}


	private function checkState () : void {
		if (_frozen) {
			throw new IllegalStateError(toString() + " is frozen");
		}
	}

	public function freeze () : void {
		_frozen = true;
	}
	
	public function get frozen () : Boolean {
		return _frozen;
	}
	
	
	public function toString () : String {
		return "ObjectDefinition for Class " + _type.name;
	}
	
	
}

}
