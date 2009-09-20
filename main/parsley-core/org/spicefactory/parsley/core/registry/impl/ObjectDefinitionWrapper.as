/*
 * Copyright 2009 the original author or authors.
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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.ConstructorArgRegistry;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.MethodRegistry;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;
import org.spicefactory.parsley.core.registry.definition.PropertyRegistry;
import org.spicefactory.parsley.core.registry.model.AsyncInitConfig;

/**
 * @author Jens Halm
 */
public class ObjectDefinitionWrapper implements RootObjectDefinition {


	private var _id:String;
	private var _lazy:Boolean;
	private var _singleton:Boolean;
	private var wrappedDefintion:ObjectDefinition;


	/**
	 * Creates a new instance.
	 * 
	 * @param wrappedDefinition the definition to wrap
	 * @param id the id the object should be registered with
	 * @param lazy whether the object is lazy initializing
	 * @param singleton whether the object should be treated as a singleton
	 */
	function ObjectDefinitionWrapper (wrappedDefinition:ObjectDefinition, id:String = null, 
			lazy:Boolean = false, singleton:Boolean = true) : void {
		this.wrappedDefintion = wrappedDefinition;
		_id = (id != null) ? id : IdGenerator.nextObjectId;
		_lazy = lazy;
		_singleton = singleton;
	}


	public function get id () : String {
		return _id;
	}
	
	public function get lazy () : Boolean {
		return _lazy;
	}
	
	public function get singleton () : Boolean {
		return _singleton;
	}
	
	public function freeze () : void {
		wrappedDefintion.freeze();
	}

	public function get type () : ClassInfo {
		return wrappedDefintion.type;
	}

	public function get instantiator () : ObjectInstantiator {
		return wrappedDefintion.instantiator;
	}
	
	public function get constructorArgs () : ConstructorArgRegistry {
		return wrappedDefintion.constructorArgs;
	}
	
	public function get properties () : PropertyRegistry {
		return wrappedDefintion.properties;
	}

	public function get injectorMethods () : MethodRegistry {
		return wrappedDefintion.injectorMethods;
	}

	public function get objectLifecycle () : LifecycleListenerRegistry {
		return wrappedDefintion.objectLifecycle;
	}
	
	public function get asyncInitConfig () : AsyncInitConfig {
		return wrappedDefintion.asyncInitConfig;
	}

	public function get frozen () : Boolean {
		return wrappedDefintion.frozen;
	}

	public function set instantiator (value:ObjectInstantiator) : void {
		wrappedDefintion.instantiator = value;
	}

	public function set asyncInitConfig (config:AsyncInitConfig) : void {
		wrappedDefintion.asyncInitConfig = config;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get initMethod () : String {
		return wrappedDefintion.initMethod;
	}

	/**
	 * @inheritDoc
	 */
	public function set initMethod (name:String) : void {
		wrappedDefintion.initMethod = name;
	}

	/**
	 * @inheritDoc
	 */
	public function get destroyMethod () : String {
		return wrappedDefintion.destroyMethod;
	}

	/**
	 * @inheritDoc
	 */
	public function set destroyMethod (name:String) : void {
		wrappedDefintion.destroyMethod = name;
	}
	
	
}
}
