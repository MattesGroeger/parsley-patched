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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.SingletonLifecycleListenerRegistry;

/**
 * Default implementation of the RootObjectDefinition interface.
 * 
 * @author Jens Halm
 */
public class DefaultRootObjectDefinition extends AbstractObjectDefinition implements RootObjectDefinition {


	private var _id:String;
	private var _lazy:Boolean;
	private var _singleton:Boolean;
	private var _order:int;

	private var _singletonListeners:LifecycleListenerRegistry;

	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 * @param id the id the object should be registered with
	 * @param registry the registry this definition belongs to
	 * @param lazy whether the object is lazy initializing
	 * @param singleton whether the object should be treated as a singleton
	 * @param order the initialization order for non-lazy singletons
	 */
	function DefaultRootObjectDefinition (type:ClassInfo, id:String, registry:ObjectDefinitionRegistry,
			lazy:Boolean = false, singleton:Boolean = true, order:int = int.MAX_VALUE):void {
		super(type);
		_id = id;
		_lazy = lazy;
		_singleton = singleton;
		_order = order;
		if (singleton && !lazy) {
			_singletonListeners = new SingletonLifecycleListenerRegistry(this, registry);
		}
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		return _id;
	}

	/**
	 * @inheritDoc
	 */
	public function get lazy () : Boolean {
		return _lazy;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get singleton () : Boolean {
		return _singleton;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get order () : int {
		return _order;
	}
	
	/**
	 * @private
	 */
	public override function get objectLifecycle () : LifecycleListenerRegistry {
		return (_singletonListeners != null) ? _singletonListeners : super.objectLifecycle;
	}
	
	
}

}
