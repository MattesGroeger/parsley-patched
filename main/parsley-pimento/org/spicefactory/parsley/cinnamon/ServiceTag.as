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

package org.spicefactory.parsley.cinnamon {
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;

import flash.errors.IllegalOperationError;

/**
 * @author Jens Halm
 */
public class ServiceTag implements ObjectDefinitionFactory {
	
            
	public var id:String;

	[Required]
	public var name:String;
	
	[Required]
	public var type:Class;
	
	public var channel:String;
	
	public var timeout:uint = 0;
	
	
	public function createRootDefinition (registry:ObjectDefinitionRegistry) : RootObjectDefinition {
		if (id == null) id = name;
		var factory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(type, id);
		var definition:RootObjectDefinition = factory.createRootDefinition(registry);
		definition.lifecycleListeners.addLifecycleListener(new ServiceLifecycleListener(this));
		return definition;
	}

	public function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		throw new IllegalOperationError("Services must be defined as root objects");
	}
}
}

import org.spicefactory.cinnamon.service.ServiceChannel;
import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.parsley.cinnamon.ServiceTag;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;

class ServiceLifecycleListener implements ObjectLifecycleListener {

	private var tag:ServiceTag;
	
	function ServiceLifecycleListener (tag:ServiceTag) {
		this.tag = tag;
	}

	public function postConstruct (instance:Object, context:Context):void {
		var channelInstance:ServiceChannel;
		if (tag.channel != null) {
			var channelRef:Object = context.getObject(tag.channel);
			if (!(channelRef is ServiceChannel)) {
				throw new ContextError("Object with id " + tag.channel + " does not implement ServiceChannel");
			}
			channelInstance = channelRef as ServiceChannel;
		}
		else {
			channelInstance = context.getObjectByType(ServiceChannel, true) as ServiceChannel;
		}
		var proxy:ServiceProxy = channelInstance.createProxy(tag.name, instance);
		if (tag.timeout != 0) proxy.timeout = tag.timeout;
	}
	
	public function preDestroy (instance:Object, context:Context) : void {
		/* ignore */
	}
	
}

