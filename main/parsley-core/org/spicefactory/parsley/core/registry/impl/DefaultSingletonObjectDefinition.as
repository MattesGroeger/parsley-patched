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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.AsyncInitConfig;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;
import org.spicefactory.parsley.core.registry.definition.impl.SingletonLifecycleListenerRegistry;

/**
 * Default implementation of the SingletonObjectDefinition interface.
 * 
 * @author Jens Halm
 */
public class DefaultSingletonObjectDefinition extends AbstractObjectDefinition implements SingletonObjectDefinition {


	private var _lazy:Boolean;
	private var _order:int;
	private var _asyncInitConfig:AsyncInitConfig;
	private var _parent:SingletonObjectDefinition;

	private var _singletonListeners:LifecycleListenerRegistry;

	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 * @param id the id the object should be registered with
	 * @param registry the registry this definition belongs to
	 * @param lazy whether the object is lazy initializing
	 * @param order the initialization order for non-lazy singletons
	 * @param parent the parent definition containing shared configuration for this definition
	 */
	function DefaultSingletonObjectDefinition (type:ClassInfo, id:String, registry:ObjectDefinitionRegistry,
			lazy:Boolean = false, order:int = int.MAX_VALUE, parent:ObjectDefinition = null) {
		super(type, id, registry, parent);
		_lazy = lazy;
		_order = order;
		_singletonListeners = new SingletonLifecycleListenerRegistry(this, registry);
		if (parent is SingletonObjectDefinition) {
			_parent = SingletonObjectDefinition(parent);
		}
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
	public function get order () : int {
		return _order;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get asyncInitConfig () : AsyncInitConfig {
		return (_asyncInitConfig) ? _asyncInitConfig : ((_parent) ? _parent.asyncInitConfig : null);
	}
	
	/**
	 * @inheritDoc
	 */
	public function set asyncInitConfig (config:AsyncInitConfig) : void {
		_asyncInitConfig = config;
	}
	
	/**
	 * @private
	 */
	public override function get objectLifecycle () : LifecycleListenerRegistry {
		return _singletonListeners;
	}
	
	
}

}
