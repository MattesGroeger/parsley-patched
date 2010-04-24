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

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
import org.spicefactory.parsley.core.registry.definition.ConstructorArgRegistry;
import org.spicefactory.parsley.core.registry.definition.ContainerObjectInstantiator;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.MethodRegistry;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;
import org.spicefactory.parsley.core.registry.definition.PropertyRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultConstructorArgRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultLifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultMethodRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.DefaultPropertyRegistry;

/** 
 * Abstract base class for all ObjectDefinition implementations.
 * 
 * @author Jens Halm
 */
public class AbstractObjectDefinition implements ObjectDefinition {

	
	private var _type:ClassInfo;
	
	private var _instantiator:ObjectInstantiator;
    private var _processorFactories:Array = new Array();	
	
	private var _initMethod:String;
	private var _destroyMethod:String;

	private var _frozen:Boolean;


	/* deprecated */
	private var _constructorArgs:ConstructorArgRegistry;
	private var _properties:PropertyRegistry;
	private var _methods:MethodRegistry;
	private var _listeners:LifecycleListenerRegistry;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 */
	function AbstractObjectDefinition (type:ClassInfo) {
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
		_listeners = definition.objectLifecycle;
		
		_initMethod = definition.initMethod;
		_destroyMethod = definition.destroyMethod;
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
	public function get objectLifecycle () : LifecycleListenerRegistry {
		return _listeners;
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
	public function addProcessorFactory (factory:ObjectProcessorFactory) : void {
		_processorFactories.push(factory);
	}

	/**
	 * @inheritDoc
	 */
	public function addProcessorFactoryMethod (method:Function) : void {
		_processorFactories.push(new ObjectProcessorFactoryMethod(method));
	}
	
	/**
	 * @inheritDoc
	 */
	public function get processorFactories () : Array {
		return _processorFactories.concat();
	}

	/**
	 * @inheritDoc
	 */
	public function set instantiator (value:ObjectInstantiator) : void {
		checkState();
		if (_instantiator != null && (_instantiator is ContainerObjectInstantiator)) {
			throw IllegalStateError("Instantiator has been set by the container and cannot be overwritten");
		}
		_instantiator = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get initMethod () : String {
		return _initMethod;
	}

	/**
	 * @inheritDoc
	 */
	public function set initMethod (name:String) : void {
		checkState();
		checkMethodName(name);
		_initMethod = name;
	}

	/**
	 * @inheritDoc
	 */
	public function get destroyMethod () : String {
		return _destroyMethod;
	}

	/**
	 * @inheritDoc
	 */
	public function set destroyMethod (name:String) : void {
		checkState();
		checkMethodName(name);
		_destroyMethod = name;
	}

	private function checkMethodName (name:String) : void {
		if (type.getMethod(name) == null) {
			throw new IllegalArgumentError("Class " + type.name 
					+ " does not contain a method with name " + name);
		}
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

import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectProcessor;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;

class ObjectProcessorFactoryMethod implements ObjectProcessorFactory {

    private var _method:Function;

	function ObjectProcessorFactoryMethod (method:Function) {
		_method = method;
	}

	public function createInstance (target:ManagedObject) : ObjectProcessor {
		var processor:Object = _method(target);
		if (!(processor is ObjectProcessor)) {
			throw new ContextError("Instance created by processor factory method does not implement ObjectProcessor: " 
					+ processor);
		}
		return processor as ObjectProcessor;
	}
	
}


