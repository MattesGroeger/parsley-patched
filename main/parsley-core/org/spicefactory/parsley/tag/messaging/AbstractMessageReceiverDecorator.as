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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.context.provider.Provider;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.scopes.ScopeManager;
import org.spicefactory.parsley.tag.core.NestedTag;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Abstract base class for decorators used for message receivers.
 * When creating tags that support all the standard receiver tag attributes 
 * (type, selector, scope), it is recommended to extend AbstractStandardReceiverDecorator
 * instead since that class already contains these three properties.
 * 
 * @author Jens Halm
 */
public class AbstractMessageReceiverDecorator implements NestedTag {
	
	
	private var _domain:ApplicationDomain;	
	
	private var receivers:Dictionary = new Dictionary();
	private var singletonReceiver:MessageReceiver;
	

	/**
	 * The ApplicationDomain associated with the registry this decorator belongs to.
	 */
	protected function get domain () : ApplicationDomain {
		return _domain;		
	}
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		_domain = registry.domain;
		if (definition is RootObjectDefinition) {
			var rootDef:RootObjectDefinition = RootObjectDefinition(definition);
			if (rootDef.singleton && !rootDef.lazy) {
				/* 
				 * For non-lazy singletons we must register a proxy so that a matching message
				 * may trigger instance creation. Otherwise the receiver may miss a message
				 * just because of the initialization order. 
				 */
				var provider:ObjectProvider = registry.createObjectProvider(rootDef.type.getClass(), rootDef.id);
				singletonReceiver = createReceiver(provider, registry.scopeManager);
			}
		} 
		if (singletonReceiver == null) {
			/*
			 * For all other use cases we wait until the object is instantiated before
			 * registering it as a message receiver.
			 */
			definition.objectLifecycle.addListener(ObjectLifecycle.POST_INIT, postInit);
		}
		definition.objectLifecycle.addListener(ObjectLifecycle.PRE_DESTROY, preDestroy);
		return definition;
	}

	/*
	 * Executed only for objects which are not non-lazy singletons.
	 */
	private function postInit (instance:Object, context:Context) : void {
		var receiver:MessageReceiver = createReceiver(Provider.forInstance(instance, domain), context.scopeManager);
		if (receivers[instance] != undefined) {
			throw new IllegalArgumentError("Attempt to add more than one receiver for the same instance: " + instance);
		}
		receivers[instance] = receiver;
	}
	
	/*
	 * Executed for all objects.
	 */
	private function preDestroy (instance:Object, context:Context) : void {
		if (singletonReceiver != null) {
			removeReceiver(singletonReceiver, context.scopeManager);
		}
		else {
			if (receivers[instance] == undefined) {
				throw new IllegalArgumentError("No MesssageTarget was added for the specified instance: " + instance);
			}
			removeReceiver(receivers[instance] as MessageReceiver, context.scopeManager);
			delete receivers[instance];
		}
	}


	protected function createReceiver (provider:ObjectProvider, scopeManager:ScopeManager) : MessageReceiver {
		throw new AbstractMethodError();
	}
	
	protected function removeReceiver (receiver:MessageReceiver, scopeManager:ScopeManager) : void {
		throw new AbstractMethodError();
	}
	
	
}
}
