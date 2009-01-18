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

package org.spicefactory.parsley.messaging.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.messaging.MessageDispatcher;
import org.spicefactory.parsley.messaging.MessageProcessor;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultMessageDispatcher implements MessageDispatcher {
	
	
	private var targets:Array;
	private var cache:Dictionary;
	
	
	/**
	 * Creates a new instance.
	 */
	function DefaultMessageDispatcher () {
		init();
	}
	
	
	private function init () : void {
		targets = new Array();
		cache = new Dictionary();
	}
	
	
	public function dispatchMessage (message:Object) : void {
		var type:ClassInfo = ClassInfo.forInstance(message);
		var targetSelection:MessageTargetSelection = null;
		
		if (cache[type.getClass()] != null) {
			targetSelection = cache[type.getClass()];
		}
		else {
			targetSelection = new MessageTargetSelection(type);
			cache[type.getClass()] = targetSelection;
			for each (var target:MessageTarget in targets) {
				if (type.isType(target.messageType.getClass())) {
					targetSelection.addTarget(target);
				}
			}
		}
		
		var selectorValue:* = targetSelection.getSelectorValue(message);
		var processor:MessageProcessor = new DefaultMessageProcessor(message, 
				targetSelection.getTargets(selectorValue), targetSelection.getInterceptors(selectorValue));
		processor.proceed();
	}	
	
	
	public function registerMessageBinding (targetInstance:Object, targetProperty:String, 
			messageType:Class, messageProperty:String, selector:* = undefined) : void {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance);
		var resolvedTargetProperty:Property = targetType.getProperty(targetProperty);
		if (resolvedTargetProperty == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a property with name " + targetProperty);	
		}
		else if (!resolvedTargetProperty.writable) {
			throw new ContextError("Target property with name " + targetProperty + " of type " + targetType.name 
					+ " is not writable");
		}
		var messageTypeInfo:ClassInfo = ClassInfo.forClass(messageType);
		var resolvedMessageProperty:Property = messageTypeInfo.getProperty(messageProperty);
		if (resolvedMessageProperty == null) {
			throw new ContextError("Message type " + messageTypeInfo.name 
					+ " does not contain a property with name " + messageProperty);	
		}
		else if (!resolvedMessageProperty.readable) {
			throw new ContextError("Message property with name " + messageProperty + " of type " + messageTypeInfo.name 
					+ " is not readable");
		}
		targets.push(new MessageBinding(targetInstance, resolvedTargetProperty, messageTypeInfo, resolvedMessageProperty, selector));
	}
	
	public function registerMessageHandler (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, messageProperties:Array = null, selector:* = undefined) : void {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance);
		var resolvedTargetMethod:Method = targetType.getMethod(targetMethod);
		if (resolvedTargetMethod == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a method with name " + targetMethod);
		}
		var params:Array = resolvedTargetMethod.parameters;
		if (messageType == null) messageType = Object;
		var messageTypeInfo:ClassInfo = ClassInfo.forClass(messageType);
		var resolvedMessageProperties:Array = null;
		if (messageProperties != null) {
			for each (var messageProperty:String in messageProperties) {
				var resolvedMessageProperty:Property = messageTypeInfo.getProperty(messageProperty);
				if (resolvedMessageProperty == null) {
					throw new ContextError("Message type " + messageTypeInfo.name 
							+ " does not contain a property with name " + messageProperty);	
				}
				else if (!resolvedMessageProperty.readable) {
					throw new ContextError("Message property with name " + messageProperty + " of type " + messageTypeInfo.name 
							+ " is not readable");
				}
				resolvedMessageProperties.push(resolvedMessageProperty);
			}
			var requiredParams:uint = 0;
			for each (var param:Parameter in params) {
				if (param.required) requiredParams++;
			}
			if (requiredParams > resolvedMessageProperties.length) {
				throw new ContextError("Parameter count of target method with name " + targetMethod + " of type " + targetType.name 
					+ " does not match the number of message properties. Required: " + resolvedMessageProperties.length 
					+ " - actual: " + params.length);
				// We'll ignore if the the number of required params is less that needed, 
				// since we can't reflect on varargs in AS3.
			}
		} 
		else if (params.length == null) {
			resolvedMessageProperties = new Array();
		}
		else {
			// message instance will be used as parameter
			if (params.length != 1) {
				throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
					+ ": Method must have exactly one parameter. " +
					"If no messageProperties are specified, the message itself will be used as a parameter");
			}
			var paramType:ClassInfo = Parameter(params[0]).type;
			if (!messageTypeInfo.isType(paramType.getClass())) {
				throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
					+ ": Method parameter of type " + paramType.name
					+ " is not applicable to message type " + messageTypeInfo.name);
			} 
		}
		targets.push(new MessageHandler(targetInstance, resolvedTargetMethod, messageTypeInfo, resolvedMessageProperties, selector));
	}
	
	public function registerMessageInterceptor (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, selector:* = undefined) : void {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance);
		var resolvedTargetMethod:Method = targetType.getMethod(targetMethod);
		if (resolvedTargetMethod == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a method with name " + targetMethod);
		}
		var params:Array = resolvedTargetMethod.parameters;
		if (messageType == null) messageType = Object;
		var messageTypeInfo:ClassInfo = ClassInfo.forClass(messageType);
		if (params.length != 1) {
			throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
				+ ": Method must have exactly one parameter of type org.spicefactory.parsley.messaging.MessageProcessor.");
		}
		var paramType:ClassInfo = Parameter(params[0]).type;
		if (paramType.getClass() != MessageProcessor) {
			throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
				+ ": Method must have exactly one parameter of type org.spicefactory.parsley.messaging.MessageProcessor.");
		} 
		targets.push(new MessageInterceptor(targetInstance, resolvedTargetMethod, messageTypeInfo, selector));
	}
	
	
	/*
	public function unregisterTarget () : void {
	}
	
	public function unregisterInterceptor () : void {
	}
	*/
	
	
	public function destroy () : void {
		init();
	}
	

}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.messaging.MessageProcessor;

class MessageBinding extends MessageTarget {

	public var targetProperty:Property;
	public var messageProperty:Property;
	
	function MessageBinding (targetInstance:Object, targetProperty:Property, 
			messageType:ClassInfo, messageProperty:Property, selector:*) {
		super(targetInstance, messageType, selector, false);
		this.targetProperty = targetProperty;
		this.messageProperty = messageProperty;
	}

	public override function handleMessage (processor:MessageProcessor) : void {
		var value:* = messageProperty.getValue(processor.message);
		targetProperty.setValue(targetInstance, value);
	}
	
} 

class MessageHandler extends MessageTarget {

	public var targetMethod:Method;
	public var messageProperties:Array;

	function MessageHandler (targetInstance:Object, targetMethod:Method, 
			messageType:ClassInfo, messageProperties:Array, selector:*) {
		super(targetInstance, messageType, selector, false);
		this.targetMethod = targetMethod;
		this.messageProperties = messageProperties;
	}
		
	public override function handleMessage (processor:MessageProcessor) : void {
		if (messageProperties == null) {
			targetMethod.invoke(targetInstance, [processor.message]);
		}
		else {
			var params:Array = new Array();
			for each (var messageProperty:Property in messageProperties) {
				var value:* = messageProperty.getValue(processor.message);
				params.push(value);
			}
			targetMethod.invoke(targetInstance, params);
		}
	}
	
}

class MessageInterceptor extends MessageTarget {

	public var targetMethod:Method;

	function MessageInterceptor (targetInstance:Object, targetMethod:Method, 
			messageType:ClassInfo, selector:*) {
		super(targetInstance, messageType, selector, true);
		this.targetMethod = targetMethod;
	}
		
	public override function handleMessage (processor:MessageProcessor) : void {
		targetMethod.invoke(targetInstance, [processor]);
	}
	
}


