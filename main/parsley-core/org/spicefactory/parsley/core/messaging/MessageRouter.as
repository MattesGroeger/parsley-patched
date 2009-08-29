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

package org.spicefactory.parsley.core.messaging {
import flash.system.ApplicationDomain;

/**
 * The central message routing facility. Usually only a single instance 
 * that all Context instance will share will be used.
 * 
 * @author Jens Halm
 */
public interface MessageRouter {
	
	
	/**
	 * Registers a message binding. The specified target property will be updated each time
	 * a message of a matching type gets dispatched through this router.
	 * 
	 * @param targetInstance the instance that contains the target property
	 * @param targetProperty the name of the target property that should be bound
	 * @param messageType the type of the message
	 * @param messageProperty the name of the property of the message that should be bound to the target property
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param domain the ApplicationDomain for reflecting on the targetInstance and messageType
	 */
	function registerMessageBinding (targetInstance:Object, targetProperty:String, 
			messageType:Class, messageProperty:String, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget;
	
	/**
	 * Registers a message handler. The specified target method will be invoked each time
	 * a message of a matching type gets dispatched through this router. Unless the <code>messageProperties</code>
	 * parameter is used the target method must have a single parameter matching the type of the method.
	 * 
	 * @param targetInstance the instance that contains the target method
	 * @param targetMethod the name of the target method that should be invoked
	 * @param messageType the type of the message or null if it should be autodetected by the parameter of the target method
	 * @param messageProperties an optional list of names of properties of the message that should be used as method
	 * parameters instead of the message itself
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param domain the ApplicationDomain for reflecting on the targetInstance and messageType
	 */
	function registerMessageHandler (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, messageProperties:Array = null, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget;
	
	/**
	 * Registers a message interceptor. The specified target method will be invoked each time
	 * a message of a matching type gets dispatched through this router.
	 * The target method must have a single parameter of type <code>org.spicefactory.parsley.messaging.MessageProcessor</code>.
	 * 
	 * @param targetInstance the instance that contains the interceptor method
	 * @param targetMethod the name of the interceptor method that should be invoked
	 * @param messageType the type of the message
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param domain the ApplicationDomain for reflecting on the targetInstance and messageType
	 */	
	function registerMessageInterceptor (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget;
		
	/**
	 * Dispatches the specified message, processing all interceptors, handlers and bindings that have
	 * registered for that message type.
	 * 
	 * @param message the message to dispatch
	 * @param domain the ApplicationDomain for reflecting on the type of the message
	 */	
	function dispatchMessage (message:Object, domain:ApplicationDomain = null) : void;
	
	
}
}
