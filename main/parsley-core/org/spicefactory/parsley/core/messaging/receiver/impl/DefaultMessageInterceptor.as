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

package org.spicefactory.parsley.core.messaging.receiver.impl {
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;

/**
 * @author Jens Halm
 */
public class DefaultMessageInterceptor extends AbstractMethodReceiver implements MessageInterceptor {


	/*
	 * Creates a new instance.
	 * The target method must have a single parameter of type <code>org.spicefactory.parsley.messaging.MessageProcessor</code>.
	 * 
	 * @param targetInstance the instance that contains the interceptor method
	 * @param methodName the name of the interceptor method that should be invoked
	 * @param messageType the type of the message to intercept
	 * @param selector an optional selector value to be used for selecting matching message targets
	 */	
	function DefaultMessageInterceptor (provider:TargetInstanceProvider, methodName:String, messageType:Class,
			selector:* = undefined) {
		super(provider, methodName, messageType, selector);
		var params:Array = targetMethod.parameters;
		if (params.length != 1 || Parameter(params[0]).type.getClass() != MessageProcessor) {
			throw new ContextError("Target " + targetMethod 
				+ ": Method must have exactly one parameter of type org.spicefactory.parsley.core.messaging.MessageProcessor.");
		}
	}
	
	
	public function intercept (processor:MessageProcessor) : void {
		targetMethod.invoke(targetInstance, [processor]);
	}
	
	
}
}
