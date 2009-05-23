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

package org.spicefactory.parsley.pimento {
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
	
	public var config:String;
	
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

import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;
import org.spicefactory.parsley.pimento.ServiceTag;
import org.spicefactory.pimento.config.PimentoConfig;

import flash.utils.getQualifiedClassName;class ServiceLifecycleListener implements ObjectLifecycleListener {

	private var tag:ServiceTag;
	
	function ServiceLifecycleListener (tag:ServiceTag) {
		this.tag = tag;
	}

	public function postConstruct (instance:Object, context:Context):void {
		var configInstance:PimentoConfig;
		if (tag.config != null) {
			var configRef:Object = context.getObject(tag.config);
			if (!(configRef is PimentoConfig)) {
				throw new ContextError("Object with id " + tag.config + " is not a PimentoConfig instance");
			}
			configInstance = configRef as PimentoConfig;
		}
		else {
			configInstance = context.getObjectByType(PimentoConfig, true) as PimentoConfig;
		}
		configInstance.addService(tag.name, instance);
		var proxy:ServiceProxy = ServiceProxy.forService(instance);
		if (tag.timeout != 0) proxy.timeout = tag.timeout;
	}
	
	public function preDestroy (instance:Object, context:Context) : void {
		/* ignore */
	}
	
}
