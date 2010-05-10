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

package org.spicefactory.parsley.processor.messaging {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.messaging.impl.MessageDispatcherFunctionReference;
import org.spicefactory.parsley.core.registry.ObjectProcessor;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;

/**
 * Processor that injects a message dispatcher function into the target object for 
 * routing messages through the frameworks messaging system.
 * 
 * @author Jens Halm
 */
public class MessageDispatcherProcessor implements ObjectProcessor {
	
	
	private var target:ManagedObject;
	private var property:Property;
	private var dispatcher:MessageDispatcherFunctionReference;
	
	
	/**
	 * Creates a new processor instance.
	 * 
	 * @param target the target to listen to
	 * @param property the property to inject the dispatcher into
	 * @param dispatcher the actual dispatcher object
	 */
	function MessageDispatcherProcessor (target:ManagedObject, property:Property, dispatcher:MessageDispatcherFunctionReference) {
		this.target = target;
		this.property = property;
		this.dispatcher = dispatcher;
	}

	
	/**
	 * @inheritDoc
	 */
	public function preInit () : void {
		property.setValue(target.instance, dispatcher.dispatchMessage);
	}
	
	/**
	 * @inheritDoc
	 */
	public function postDestroy () : void {
		dispatcher.disable();
		
	}
	
	
	/**
	 * Creates a new processor factory.
	 * 
	 * @param property the property to inject the dispatcher into
	 * @param dispatcher the actual dispatcher object
	 * @return a new processor factory
	 */
	public static function newFactory (property:Property, dispatcher:MessageDispatcherFunctionReference) : ObjectProcessorFactory {
		return ObjectProcessorFactories.newFactory(MessageDispatcherProcessor, [property, dispatcher]);
	}
	
	
}
}

