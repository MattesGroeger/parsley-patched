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
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.tag.RootConfigurationTag;

[DefaultProperty("decorators")]

/**
 * Represents the root DynamicCommand tag for an object definition in MXML or XML configuration.
 * A dynamic command is a special type of object that only gets created when a matching
 * message was dispatched. If the <code>stateful</code> property is false (the default)
 * a new instance will be created for each matching message. This tag supports all
 * child tags that the regular Object tag supports.
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
		
		var messageInfo:ClassInfo = ClassInfo.forClass(messageType, registry.domain);
		
		/* message receivers will be created on demand - we create mocks here just for using
		   the validation logic of these receiver implementations early */
		var provider:ObjectProvider = new MockObjectProvider(targetDef.type);
		var invoker:CommandTarget 
				= new DynamicCommandTarget(provider, execute, selector, messageInfo, messageProperties, order);
		
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
				execute, result, error, invoker.returnType, messageProperties);
				
		registry.scopeManager.getScope(scope).messageReceivers.addCommand(target);
		
		registry.context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}

	
	private function contextDestroyed (event:ContextEvent) : void {
		Context(event.target).scopeManager.getScope(scope).messageReceivers.removeCommand(target);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.DynamicContext;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.context.provider.Provider;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandProcessor;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.CommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.impl.AbstractMessageReceiver;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultCommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultCommandTarget;
import org.spicefactory.parsley.core.registry.ObjectDefinition;

import flash.errors.IllegalOperationError;

class DynamicCommandProxy extends AbstractMessageReceiver implements CommandTarget {
	
	private var context:DynamicContext;
	private var definition:ObjectDefinition;
	private var stateful:Boolean;
	
	private var execute:String;
	private var result:String;
	private var error:String;
	
	private var messageInfo:ClassInfo;
	private var messageProperties:Array;
	private var _returnType:Class;
	
	private var statelessTarget:DynamicObject;
	
	function DynamicCommandProxy (
			messageInfo:ClassInfo, 
			selector:*, 
			order:int, 
			context:DynamicContext,
			definition:ObjectDefinition,
			stateful:Boolean,
			execute:String,
			result:String,
			error:String,
			returnType:Class,
			messageProperties:Array
			) {
				
		super(messageInfo.getClass(), selector, order);
		
		this.definition = definition;
		this.context = context;
		this.stateful = stateful;
		this.execute = execute;
		this.result = result;
		this.error = error;
		
		this.messageInfo = messageInfo;
		this.messageProperties = messageProperties;
		_returnType = returnType;
	}

	public function get returnType () : Class {
		return _returnType;
	}
	
	public function executeCommand (processor:CommandProcessor) : void {
		
		var object:DynamicObject = createObject();
		
		var command:Command;
		try {
			var invoker:DynamicCommandTarget
					= new DynamicCommandTarget(Provider.forInstance(object.instance), execute, 
					selector, messageInfo, messageProperties, order);
					
			var returnValue:* = invoker.invoke(processor.message);
			command = processor.process(returnValue);
		}
		catch (e:Error) {
			object.remove();
			throw e;
		}
		if (result != null) {
			var resultHandler:CommandObserver
					= new DynamicCommandObserver(object, stateful, result, CommandStatus.COMPLETE, 
					selector, messageInfo, int.MIN_VALUE);
			command.addObserver(resultHandler);
		}
		if (error != null) {
			var errorHandler:CommandObserver
					= new DynamicCommandObserver(object, stateful, error, CommandStatus.ERROR, 
					selector, messageInfo, int.MIN_VALUE);
			command.addObserver(errorHandler);
		}
		if (!stateful) {
			command.addStatusHandler(checkCommandStatus, object, (result != null), (error != null));
		}
	}
	
	private function createObject () : DynamicObject {
		if (!stateful) {
			return context.addDefinition(definition);
		}
		else {
			if (statelessTarget == null) {
				statelessTarget = context.addDefinition(definition);			
			}
			return statelessTarget;
		}
	}
	
	private function checkCommandStatus (command:Command, object:DynamicObject,
			ignoreComplete:Boolean, ignoreError:Boolean) : void {
				
		var status:CommandStatus = command.status;
		if (status == CommandStatus.CANCEL 
				|| (status == CommandStatus.COMPLETE && !ignoreComplete)
				|| (status == CommandStatus.ERROR && !ignoreError)
				) {
			object.remove();		
		}
	}
	
	
}

class DynamicCommandTarget extends DefaultCommandTarget {
	
	function DynamicCommandTarget (
			provider:ObjectProvider, 
			methodName:String, 
			selector:*, 
			messageType:ClassInfo, 
			messageProperties:Array, 
			order:int
			) {
		super(provider, methodName, selector, messageType, messageProperties, order);
	}
	
	public function invoke (message:Object) : * {
		return invokeMethod(message);
	}
	
}

class DynamicCommandObserver extends DefaultCommandObserver {
	
	private var object:DynamicObject;
	private var stateful:Boolean;
	
	function DynamicCommandObserver (
			object:DynamicObject, 
			stateful:Boolean, 
			methodName:String, 
			status:CommandStatus, 
			selector:* = undefined, 
			messageType:ClassInfo = null, 
			order:int = int.MAX_VALUE
			) {
		super(Provider.forInstance(object.instance), methodName, status, selector, messageType, order);
		this.object = object;
		this.stateful = stateful;
	}

	public override function observeCommand (command:Command) : void {
		try {
			super.observeCommand(command);
		}
		finally {
			if (!stateful) {
				object.remove();
			}
		}
	}
	
}

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
