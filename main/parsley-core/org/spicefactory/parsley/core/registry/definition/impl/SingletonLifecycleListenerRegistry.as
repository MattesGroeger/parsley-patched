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

package org.spicefactory.parsley.core.registry.definition.impl {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.context.provider.SynchronizedObjectProvider;
import org.spicefactory.parsley.core.events.ObjectDefinitionRegistryEvent;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.LifecycleListenerRegistry;

import flash.events.Event;

/**
 * Extends the default implementation of the LifecycleListenerRegistry interface and
 * adds special synchronization required for singleton ObjectProviders.
 * These are primarily needed to prevent that a message receiver misses a message
 * only because the sender was initialized earlier on container startup.
 * 
 * @author Jens Halm
 */
public class SingletonLifecycleListenerRegistry extends DefaultLifecycleListenerRegistry {
	
	
	private var registry:ObjectDefinitionRegistry;
	private var provider:SynchronizedObjectProvider;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param definition the definition of the object this registry is associated with
	 * @param registry the registry the definition belongs to
	 */
	function SingletonLifecycleListenerRegistry (definition:RootObjectDefinition, registry:ObjectDefinitionRegistry) {
		super(definition);
		this.registry = registry;
	}

	
	/**
	 * @inheritDoc
	 */
	public override function synchronizeProvider (handler:Function) : LifecycleListenerRegistry {
		checkState();
		if (provider == null) {
			var id:String = RootObjectDefinition(definition).id;
			var providerDelegate:ObjectProvider = registry.createObjectProvider(definition.type.getClass(), id);
			provider = wrapProvider(providerDelegate);
			addListener(ObjectLifecycle.POST_DESTROY, destroyProvider);
			registry.addEventListener(ObjectDefinitionRegistryEvent.FROZEN, registryFrozen, false, 1);
		}
		addProviderHandler(handler);
		return this;
	}
	
	private function registryFrozen (event:Event) : void {
		registry.removeEventListener(ObjectDefinitionRegistryEvent.FROZEN, registryFrozen);
		invokeProviderHandlers(provider);
	}

	private function destroyProvider (instance:Object, context:Context) : void {
		invokeDestroyHandlers(provider);
		provider = null;
	}
	
	
}
}

