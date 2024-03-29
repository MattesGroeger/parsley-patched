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

package org.spicefactory.parsley.processor.messaging.receiver {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.util.MessageReceiverFactories;

/**
 * Default implementation of the CommandObserver interface.
 * 
 * @author Jens Halm
 */
public class DefaultCommandObserver extends AbstractMethodReceiver implements CommandObserver {
	
	
	private var _status:CommandStatus;
	private var maxParams:int;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param provider the provider for the instance that contains the target method
	 * @param methodName the name of the target method that should be invoked
	 * @param status the command status this object is interested in
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param messageType the type of the message or null if it should be autodetected by the parameter of the target method
	 * @param order the execution order for this receiver
	 * @param supportsResult whether a result parameter is supported in the handler method
	 */
	function DefaultCommandObserver (provider:ObjectProvider, methodName:String, status:CommandStatus, 
			selector:* = undefined, messageType:ClassInfo = null, order:int = int.MAX_VALUE, supportsResult:Boolean = true) {
		super(provider, methodName, getMessageType(provider, methodName, messageType, supportsResult), selector, order);
		_status = status;
	}

	private function getMessageType (provider:ObjectProvider, methodName:String, 
			explicitType:ClassInfo, supportsResult:Boolean) : Class {
		maxParams = (supportsResult) ? 3 : 2;
		var targetMethod:Method = provider.type.getMethod(methodName);
		if (targetMethod == null) {
			throw new ContextError("Target instance of type " + provider.type.name 
					+ " does not contain a method with name " + methodName);
		}
		var params:Array = targetMethod.parameters;
		if (params.length > maxParams) {
			throw new ContextError("Target " + targetMethod  
				+ ": At most " + maxParams + " parameter(s) allowed for this type of Command Observer.");
		}
		if (params.length >= maxParams - 1) {
			return getMessageTypeFromParameter(targetMethod, maxParams - 2, explicitType);
		}
		else if (explicitType != null) {
			return explicitType.getClass();
		}		
		return Object;
	}
		
	/**
	 * @private
	 */
	public override function get order () : int {
		if (super.order != int.MAX_VALUE) {
			return super.order;
		}
		return (targetMethod.parameters.length == maxParams) ? int.MIN_VALUE : int.MAX_VALUE;
	}
	
	/**
	 * @inheritDoc
	 */
	public function observeCommand (processor:CommandObserverProcessor) : void {
		var paramTypes:Array = targetMethod.parameters;
		var params:Array = new Array();
		if (paramTypes.length >= 1 && maxParams == 3) {
			var resultType:ClassInfo = Parameter(paramTypes[0]).type;
			params.push(processor.command.getResult(resultType));
		}
		if (paramTypes.length >= maxParams - 1) {
			params.push(processor.message);
		}
		if (paramTypes.length == maxParams) {
			params.push(processor);
		}
		targetMethod.invoke(provider.instance, params);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get status () : CommandStatus {
		return _status;
	}
	
	
	/**
	 * Creates a new factory that creates DefaultCommandObserver instances. 
	 * Such a factory can be used for convenient registration of a <code>MessageReceiverProcessorFactory</code>
	 * with a target <code>ObjectDefinition</code>.
	 * 
	 * @param methodName the name of the target method that should be invoked
	 * @param status the command status this object is interested in
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param messageType the type of the message or null if it should be autodetected by the parameter of the target method
	 * @param order the execution order for this receiver
	 * @param supportsResult whether a result parameter is supported in the handler method
	 * @return a new factory that creates DefaultCommandObserver instance
	 */
	public static function newFactory (methodName:String, status:CommandStatus, selector:* = undefined, 
			messageType:ClassInfo = null, order:int = int.MAX_VALUE, supportsResult:Boolean = true) : MessageReceiverFactory {
				
		return MessageReceiverFactories.newFactory(DefaultCommandObserver, 
				[methodName, status, selector, messageType, order, supportsResult]);
	}
	
	
}
}
