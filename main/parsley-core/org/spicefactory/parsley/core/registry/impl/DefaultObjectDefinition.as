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

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.model.AsyncInitConfig;
import org.spicefactory.parsley.core.registry.definition.MethodRegistry;
import org.spicefactory.parsley.core.registry.definition.ConstructorArgRegistry;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.PropertyRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultPropertyRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultConstructorArgRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultMethodRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultLifecycleListenerRegistry;

/** 
 * Default implementation of the ObjectDefintion interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectDefinition implements ObjectDefinition {

	
	private var _type:ClassInfo;
	
	private var _instantiator:ObjectInstantiator;
	private var _constructorArgs:ConstructorArgRegistry;
	private var _properties:PropertyRegistry;
	private var _methods:MethodRegistry;
	private var _listeners:LifecycleListenerRegistry;
	private var _asyncInitConfig:AsyncInitConfig;

	private var _frozen:Boolean;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 */
	function DefaultObjectDefinition (type:ClassInfo) {
		_type = type;
		_constructorArgs = new DefaultConstructorArgRegistry(this);
		_properties = new DefaultPropertyRegistry(this);
		_methods = new DefaultMethodRegistry(this);
		_listeners = new DefaultLifecycleListenerRegistry(this);
	}


	/**
	 * Copies the internal state of the specified definition to this instance.
	 * 
	 * @param definition the definition whose state should be copied into this instance
	 */
	public function populateFrom (definition:ObjectDefinition) : void {
		checkState();
		_instantiator = definition.instantiator;
		_constructorArgs = definition.constructorArgs;
		_properties = definition.properties;
		_methods = definition.injectorMethods;
		_listeners = definition.lifecycleListeners;
		_asyncInitConfig = definition.asyncInitConfig;
	}

	
	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return _type;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get constructorArgs () : ConstructorArgRegistry {
		return _constructorArgs;
	}

	/**
	 * @inheritDoc
	 */
	public function get properties () : PropertyRegistry {
		return _properties;
	}

	/**
	 * @inheritDoc
	 */
	public function get injectorMethods () : MethodRegistry {
		return _methods;
	}

	/**
	 * @inheritDoc
	 */
	public function get lifecycleListeners () : LifecycleListenerRegistry {
		return _listeners;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get asyncInitConfig () : AsyncInitConfig {
		return _asyncInitConfig;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set asyncInitConfig (config:AsyncInitConfig) : void {
		_asyncInitConfig = config;
	}

	/**
	 * @inheritDoc
	 */
	public function get instantiator () : ObjectInstantiator {
		return _instantiator;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set instantiator (value:ObjectInstantiator) : void {
		checkState();
		_instantiator = value;
	}


	private function checkState () : void {
		if (_frozen) {
			throw new IllegalStateError(toString() + " is frozen");
		}
	}

	/**
	 * @inheritDoc
	 */
	public function freeze () : void {
		_frozen = true;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get frozen () : Boolean {
		return _frozen;
	}
	
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "ObjectDefinition for Class " + _type.name;
	}
	
	
}

}
