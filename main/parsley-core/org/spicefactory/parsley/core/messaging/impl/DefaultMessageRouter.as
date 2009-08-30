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

package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.MessageTarget;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the MessageRouter interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageRouter implements MessageRouter {
	
	
	private var targets:Array;
	private var targetSelectionCache:Dictionary;
	
	private var deferredMessages:Array;
	private var activated:Boolean = false;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the associated context instance
	 */
	function DefaultMessageRouter (context:Context) {
		init();
		if (context.initialized) {
			activated = true;
		}
		else {
			context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);
		}
	}
	
	
	/**
	 * @inheritDoc
	 */
	private function init () : void {
		targets = new Array();
		targetSelectionCache = new Dictionary();
		deferredMessages = new Array();
	}
	
	
	private function contextInitialized (event:ContextEvent) : void {
		if (activated) return;
		activated = true;
		for each (var message:Object in deferredMessages) {
			dispatchMessage(message);
		}
		deferredMessages = new Array();
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, domain:ApplicationDomain = null) : void {
		if (!activated) {
			deferredMessages.push(message);
			return;
		}
		var type:ClassInfo = ClassInfo.forInstance(message, domain);
		var targetSelection:MessageTargetSelection = null;
		
		if (targetSelectionCache[type.getClass()] != null) {
			targetSelection = targetSelectionCache[type.getClass()];
		}
		else {
			targetSelection = new MessageTargetSelection(type);
			targetSelectionCache[type.getClass()] = targetSelection;
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
	
	/**
	 * @inheritDoc
	 */
	public function registerMessageBinding (targetInstance:Object, targetProperty:String, 
			messageType:Class, messageProperty:String, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance, domain);
		var resolvedTargetProperty:Property = targetType.getProperty(targetProperty);
		if (resolvedTargetProperty == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a property with name " + targetProperty);	
		}
		else if (!resolvedTargetProperty.writable) {
			throw new ContextError("Target property with name " + targetProperty + " of type " + targetType.name 
					+ " is not writable");
		}
		var messageTypeInfo:ClassInfo = ClassInfo.forClass(messageType, domain);
		var resolvedMessageProperty:Property = messageTypeInfo.getProperty(messageProperty);
		if (resolvedMessageProperty == null) {
			throw new ContextError("Message type " + messageTypeInfo.name 
					+ " does not contain a property with name " + messageProperty);	
		}
		else if (!resolvedMessageProperty.readable) {
			throw new ContextError("Message property with name " + messageProperty + " of type " + messageTypeInfo.name 
					+ " is not readable");
		}
		clearCache();

		var target:MessageTarget = 
			new MessageBinding(targetInstance, resolvedTargetProperty, messageTypeInfo, resolvedMessageProperty, selector, this);
		targets.push(target);
		return target;
	}
	
	/**
	 * @inheritDoc
	 */
	public function registerMessageHandler (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, messageProperties:Array = null, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance, domain);
		var resolvedTargetMethod:Method = targetType.getMethod(targetMethod);
		if (resolvedTargetMethod == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a method with name " + targetMethod);
		}
		var params:Array = resolvedTargetMethod.parameters;
		var messageTypeInfo:ClassInfo = (messageType == null) ? ClassInfo.forClass(Object) : ClassInfo.forClass(messageType, domain);
		var resolvedMessageProperties:Array = null;
		if (messageProperties != null) {
			resolvedMessageProperties = new Array();
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
		else if (params.length == 0) {
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
			if (messageType == null) {
				messageTypeInfo = paramType;
			}
			else if (!messageTypeInfo.isType(paramType.getClass())) {
				throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
					+ ": Method parameter of type " + paramType.name
					+ " is not applicable to message type " + messageTypeInfo.name);
			} 
		}
		clearCache();
		
		var target:MessageTarget = 
			new MessageHandler(targetInstance, resolvedTargetMethod, messageTypeInfo, resolvedMessageProperties, selector, this);
		targets.push(target);
		return target;
	}
	
	/**
	 * @inheritDoc
	 */
	public function registerMessageInterceptor (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, selector:* = undefined, domain:ApplicationDomain = null) : MessageTarget {
		var targetType:ClassInfo = ClassInfo.forInstance(targetInstance, domain);
		var resolvedTargetMethod:Method = targetType.getMethod(targetMethod);
		if (resolvedTargetMethod == null) {
			throw new ContextError("Target instance of type " + targetType.name 
					+ " does not contain a method with name " + targetMethod);
		}
		var params:Array = resolvedTargetMethod.parameters;
		if (messageType == null) messageType = Object;
		var messageTypeInfo:ClassInfo = ClassInfo.forClass(messageType, domain);
		if (params.length != 1) {
			throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
				+ ": Method must have exactly one parameter of type org.spicefactory.parsley.messaging.MessageProcessor.");
		}
		var paramType:ClassInfo = Parameter(params[0]).type;
		if (paramType.getClass() != MessageProcessor) {
			throw new ContextError("Target method with name " + targetMethod + " of type " + targetType.name 
				+ ": Method must have exactly one parameter of type org.spicefactory.parsley.messaging.MessageProcessor.");
		} 
		
		var target:MessageTarget = 
			new MessageInterceptor(targetInstance, resolvedTargetMethod, messageTypeInfo, selector, this);
		targets.push(target);
		return target;
	}
	

	private function clearCache () : void {
		targetSelectionCache = new Dictionary();
	}

	/**
	 * @inheritDoc
	 */
	public function unregister (target:MessageTarget) : void {
		var index:int = targets.indexOf(target);
		if (index != -1) {
			targets.splice(index, 1);
			clearCache();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		init();
	}
	

}
}

import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.MessageTarget;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageRouter;

class AbstractMessageTarget implements MessageTarget {
	
	private var _targetType:ClassInfo;
	private var _targetInstance:Object;
	
	private var _messageType:ClassInfo;
	private var _selector:*;
	
	private var _interceptor:Boolean;
	
	private var _router:DefaultMessageRouter;
	
	
	function AbstractMessageTarget (targetInstance:Object, messageType:ClassInfo, selector:*, 
			interceptor:Boolean, router:DefaultMessageRouter) {
		this._targetType = ClassInfo.forInstance(targetInstance, messageType.applicationDomain);
		this._targetInstance = targetInstance;
		this._messageType = messageType;
		this._selector = selector;
		this._interceptor = interceptor;
		this._router = router;
	}

	public function handleMessage (processor:MessageProcessor) : void {
		throw new AbstractMethodError();
	}
	
	public function unregister () : void {
		_router.unregister(this);
	}
	
	public function get targetType () : ClassInfo {
		return _targetType;
	}
	
	public function get targetInstance () : Object {
		return _targetInstance;
	}
	
	public function get messageType () : ClassInfo {
		return _messageType;
	}
	
	public function get selector () : * {
		return _selector;
	}
	
	public function get interceptor () : Boolean {
		return _interceptor;
	}
}

class MessageBinding extends AbstractMessageTarget {

	public var targetProperty:Property;
	public var messageProperty:Property;
	
	function MessageBinding (targetInstance:Object, targetProperty:Property, 
			messageType:ClassInfo, messageProperty:Property, selector:*, router:DefaultMessageRouter) {
		super(targetInstance, messageType, selector, false, router);
		this.targetProperty = targetProperty;
		this.messageProperty = messageProperty;
	}

	public override function handleMessage (processor:MessageProcessor) : void {
		var value:* = messageProperty.getValue(processor.message);
		targetProperty.setValue(targetInstance, value);
	}
	
} 

class MessageHandler extends AbstractMessageTarget {

	public var targetMethod:Method;
	public var messageProperties:Array;

	function MessageHandler (targetInstance:Object, targetMethod:Method, 
			messageType:ClassInfo, messageProperties:Array, selector:*, router:DefaultMessageRouter) {
		super(targetInstance, messageType, selector, false, router);
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

class MessageInterceptor extends AbstractMessageTarget {

	public var targetMethod:Method;

	function MessageInterceptor (targetInstance:Object, targetMethod:Method, 
			messageType:ClassInfo, selector:*, router:DefaultMessageRouter) {
		super(targetInstance, messageType, selector, true, router);
		this.targetMethod = targetMethod;
	}
		
	public override function handleMessage (processor:MessageProcessor) : void {
		targetMethod.invoke(targetInstance, [processor]);
	}
	
}

