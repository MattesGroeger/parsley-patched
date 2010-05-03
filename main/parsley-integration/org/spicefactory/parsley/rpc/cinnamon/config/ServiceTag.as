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

package org.spicefactory.parsley.rpc.cinnamon.config {
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;
import org.spicefactory.parsley.tag.RootConfigurationTag;

/**
 * Represents the Service MXML or XML tag, defining the configuration for a Cinnamon service.
 * 
 * @author Jens Halm
 */
public class ServiceTag implements RootConfigurationTag {
	
    
    /**
	 * The id that the service will be registered with in the Parsley IOC Container. Usually no need to be specified explicitly.
	 */ 
	public var id:String;

	[Required]
	/**
	 * The name of the service as configured on the server-side.
	 */
	public var name:String;
	
	[Required]
	/**
	 * The AS3 service implementation (usually generated with Pimentos Ant Task).
	 */
	public var type:Class;
	
	/**
	 * The id of the ServiceChannel instance to use for this service. Only required
	 * if you have more than one channel tag in your Context. If there is only one (like in most use cases)
	 * it will be automatically detected.
	 */
	public var channel:String;
	
	/**
	 * The request timeout in milliseconds.
	 */
	public var timeout:uint = 0;
	
	
	/**
	 * @inheritDoc
	 */
	public function process (registry:ObjectDefinitionRegistry) : void {
		if (id == null) id = name;
		var definition:SingletonObjectDefinition = registry.builders
				.forSingletonDefinition(type)
				.id(id)
				.buildAndRegister();
		definition.addProcessorFactory(ServiceProcessor.newFactory(name, channel, timeout));
	}
	
	
}
}
