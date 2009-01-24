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
import org.spicefactory.parsley.factory.ObjectInstantiator;
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.registry.ConstructorArgRegistry;
import org.spicefactory.parsley.factory.registry.MethodRegistry;
import org.spicefactory.parsley.factory.registry.PostProcessorRegistry;
import org.spicefactory.parsley.factory.registry.PropertyRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultConstructorArgRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultMethodRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultPostProcessorRegistry;
import org.spicefactory.parsley.factory.registry.impl.DefaultPropertyRegistry;
import org.spicefactory.parsley.messaging.registry.MessageTargetRegistry;
import org.spicefactory.parsley.messaging.registry.impl.DefaultMessageTargetRegistry;

/**
 * @author Jens Halm
 */
public class DefaultObjectDefinition implements ObjectDefinition {

	
	private var _type:ClassInfo;
	
	private var _constructorArgs:ConstructorArgRegistry;
	private var _properties:PropertyRegistry;
	private var _methods:MethodRegistry;
	private var _processors:PostProcessorRegistry;
	private var _messageTargets:MessageTargetRegistry;
	private var _initMethod:Method;
	private var _destroyMethod:Method;
	private var _factoryMethod:Method;
	private var _instantiator:ObjectInstantiator;

	private var _frozen:Boolean;

	
	function DefaultObjectDefinition (type:ClassInfo) {
		_type = type;
		_constructorArgs = new DefaultConstructorArgRegistry(this);
		_properties = new DefaultPropertyRegistry(this);
		_methods = new DefaultMethodRegistry(this);
		_processors = new DefaultPostProcessorRegistry(this);
		_messageTargets = new DefaultMessageTargetRegistry(this);
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

	public function get postProcessors () : PostProcessorRegistry {
		return _processors;
	}
	
	public function get messageTargets () : MessageTargetRegistry {
		return _messageTargets;
	}

	public function get initMethod () : Method {
		return _initMethod;
	}
	
	public function set initMethod (value:Method) : void {
		checkState();
		checkMethodOwner(value);
		_initMethod = value;
	}

	public function get destroyMethod () : Method {
		return _destroyMethod;
	}

	public function set destroyMethod (value:Method) : void {
		checkState();
		checkMethodOwner(value);
		_destroyMethod = value;
	}
	
	public function get factoryMethod () : Method {
		return _factoryMethod;
	}

	public function set factoryMethod (value:Method) : void {
		checkState();
		checkMethodOwner(value);
		_factoryMethod = value;
	}
	
	function get instantiator () : ObjectInstantiator {
		return _instantiator;
	}
	
	function set instantiator (value:ObjectInstantiator) : void {
		checkState();
		_instantiator = value;
	}

	private function checkMethodOwner (method:Method) : void {
		if (method.owner != _type) {
			throw new IllegalArgumentError("Method " + method.name + " is not a member of Class " + _type.name);
		}
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
