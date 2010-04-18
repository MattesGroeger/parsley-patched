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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicContext;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultCommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultCommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.impl.DynamicCommandProxy;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.tag.RootConfigurationTag;

[DefaultProperty("decorators")]

/**
 * Represents the root DynamicCommand tag for an object definition in MXML or XML configuration.
 * 
 * <p>A dynamic command is a special type of object that only gets created when a matching
 * message was dispatched. It contains only a single command execution method and optionally 
 * "private" result and error handlers that will only be called for the command executed 
 * by the same instance. In addition other object can listen for the result or error
 * values with the regular <code>[CommandResult]</code> or <code>[CommandError]</code> tags.</p>
 * 
 * <p>If the <code>stateful</code> property is false (the default) a new instance will 
 * be created for each matching message and the command object will be disposed 
 * and removed from the Context as soon as the asynchronous command completed.</p>
 *  
 * <p>This tag supports all child tags that the regular Object tag supports.</p>
 * 
 * @author Jens Halm
 */
public class DynamicCommandTag implements RootConfigurationTag {


	/**
	 * The class that executes the command.
	 */
	public var type:Class;
	
	/**
	 * @copy org.spicefactory.parsley.tag.lifecycle.AbstractSynchronizedProviderDecorator#scope
	 */
	public var scope:String = ScopeName.GLOBAL;

	/**
	 * @copy org.spicefactory.parsley.tag.messaging.AbstractMessageReceiverDecorator#type
	 */
	public var messageType:Class;

	/**
	 * @copy org.spicefactory.parsley.tag.messaging.AbstractMessageReceiverDecorator#selector
	 */
	public var selector:*;
	
	/**
	 * @copy org.spicefactory.parsley.tag.messaging.MessageHandlerDecorator#messageProperties
	 */
	public var messageProperties:Array;
		
	/**
	 * @copy org.spicefactory.parsley.tag.messaging.AbstractMessageReceiverDecorator#order
	 */
	public var order:int = int.MAX_VALUE;
	
	/**
	 * Indicates whether the target command should keep state between command executions.
	 * When this property is true, an instance will be created when the first matching
	 * message is dispatched that will then be reused for subsequent messages.
	 * When it is set to false (the default), a new instance will be created for each matching message.
	 */
	public var stateful:Boolean = false;
	
	/**
	 * The name of the method that executes the command.
	 * If omitted the default is "execute".
	 * The presence of an execution method in the 
	 * target instance is required.
	 */
	public var execute:String = "execute";
	
	/**
	 * The name of the method to invoke for the result.
	 * If omitted the framework will look for a method named "result".
	 * A result method is optional, if it does not exist no result will
	 * be passed to the command instance. 
	 */
	public var result:String;
	
	/**
	 * The name of the method to invoke in case of errors.
	 * If omitted the framework will look for a method named "error".
	 * An error method is optional, if it does not exist no error value will
	 * be passed to the command instance. 
	 */
	public var error:String;
	
	[ArrayElementType("org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator")]
	/**
	 * @copy org.spicefactory.parsley.tag.core.RootObjectTag#decorators
	 */
	public var decorators:Array = new Array();
	 

	private var target:CommandTarget;
	
	
	/**
	 * @inheritDoc
	 */
	public function process (registry:ObjectDefinitionRegistry) : void {
		
		var targetDef:ObjectDefinition = registry.builders
				.forNestedDefinition(type)
				.decorators(decorators)
				.build();
		
		var messageInfo:ClassInfo = (messageType == null) ? null : ClassInfo.forClass(messageType, registry.domain);
		
		/* message receivers will be created on demand - we create mocks here just for using
		   the validation logic of these receiver implementations early */
		var provider:ObjectProvider = new MockObjectProvider(targetDef.type);
		var invoker:CommandTarget 
				= new DefaultCommandTarget(provider, execute, selector, messageInfo, messageProperties, order);
		messageInfo = ClassInfo.forClass(invoker.messageType, registry.domain);
		
		if (result != null || targetDef.type.getMethod("result") != null) {
			if (result == null) {
				result = "result";
			}
			new DefaultCommandObserver(provider, result, CommandStatus.COMPLETE, selector, messageInfo);
		}
		if (error != null || targetDef.type.getMethod("error") != null) {
			if (error == null) {
				error = "error";
			}
			new DefaultCommandObserver(provider, error, CommandStatus.ERROR, selector, messageInfo);
		}
		
		var context:DynamicContext = registry.context.createDynamicContext();
		
		target = new DynamicCommandProxy(messageInfo, selector, order, context, targetDef, stateful,
				invoker.returnType, execute, result, error, messageProperties);
				
		registry.context.scopeManager.getScope(scope).messageReceivers.addCommand(target);
		
		registry.context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}

	
	private function contextDestroyed (event:ContextEvent) : void {
		Context(event.target).scopeManager.getScope(scope).messageReceivers.removeCommand(target);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;

import flash.errors.IllegalOperationError;

class MockObjectProvider implements ObjectProvider {

	private var _type:ClassInfo;
	
	function MockObjectProvider (type:ClassInfo) {
		_type = type;
	}

	public function get instance () : Object {
		throw new IllegalOperationError("This mock does not provide actual instances");
	}
	
	public function get type () : ClassInfo {
		return _type;
	}
	
}
