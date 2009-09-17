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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

/**
 * @author Jens Halm
 */
public class MessageHandler extends AbstractMethodReceiver implements MessageTarget {
	
	
	
	function MessageHandler (provider:TargetInstanceProvider, methodName:String, selector:* = undefined, messageType:ClassInfo = null) {
		super(provider, methodName, getMessageType(provider, methodName, messageType), selector);
	}
	

	private function getMessageType (provider:TargetInstanceProvider, methodName:String, 
			messageType:ClassInfo = null) : ClassInfo {
		var targetMethod:Method = provider.type.getMethod(methodName);
		if (targetMethod == null) {
			throw new ContextError("Target instance of type " + provider.type..name 
					+ " does not contain a method with name " + targetMethod);
		}
		var params:Array = targetMethod.parameters;
		if (params.length > 1) {
			throw new ContextError("Target " + targetMethod  
				+ ": At most one parameter allowed for a MessageHandler.");
		}
		if (params.length == 1) {
			var paramType:ClassInfo = Parameter(params[0]).type;
			if (messageType == null) {
				return paramType;
			}
			else if (!messageType.isType(paramType.getClass())) {
				throw new ContextError("Target " + targetMethod
					+ ": Method parameter of type " + paramType.name
					+ " is not applicable to message type " + messageType.name);
			}
		}
		else if (messageType == null) {
			return ClassInfo.forClass(Object);
		}			
		return messageType;
	}
	
	
	public function handleMessage (message:Object) : void {
		var params:Array = (targetMethod.parameters.length == 1) ? [message] : [];
		targetMethod.invoke(targetInstance, params);
	}
	
	
}
}
