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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.context.provider.SynchronizedObjectProvider;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.impl.CommandStatusFlag;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

[Metadata(name="CommandStatus", types="property", multiple="false")]

/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that serve as a flag
 * for indicating whether any matching asynchronous command is currently active.
 * 
 * @author Jens Halm
 */
public class CommandStatusDecorator extends AbstractMessageReceiverDecorator {
	
	
	[Target]
	/**
	 * The name of the property that serves as a status flag.
	 */
	public var property:String;
	
	
	private var messageType:ClassInfo;
	
	private var targetProperty:Property;
	
	
	/**
	 * @private
	 */
	public override function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		targetProperty = definition.type.getProperty(property);
		messageType = (type != null) ? ClassInfo.forClass(type, domain) : ClassInfo.forClass(Object);
		definition.objectLifecycle.addListener(ObjectLifecycle.PRE_CONFIGURE, initStatusFlag);
		return super.decorate(definition, registry);
	}
	
	private function initStatusFlag (instance:Object, context:Context) : void {
		targetProperty.setValue(instance, targetScope.commandManager.hasActiveCommands(messageType.getClass(), selector));
	}

	/**
	 * @private
	 */
	protected override function handleProvider (provider:SynchronizedObjectProvider) : void {
		var observers:Array = new Array();
		observers.push(createObserver(provider, messageType, CommandStatus.EXECUTE)); 
		observers.push(createObserver(provider, messageType, CommandStatus.COMPLETE)); 
		observers.push(createObserver(provider, messageType, CommandStatus.ERROR)); 
		observers.push(createObserver(provider, messageType, CommandStatus.CANCEL)); 
		provider.addDestroyHandler(removeObservers, observers);
	}
	
	private function createObserver (provider:ObjectProvider, messageType:ClassInfo, status:CommandStatus) : CommandObserver {
		var observer:CommandObserver 
			= new CommandStatusFlag(provider, property, targetScope.commandManager, status, messageType, selector, order);
		targetScope.messageReceivers.addCommandObserver(observer);
		return observer;		
	}
	
	private function removeObservers (observers:Array) : void {
		for each (var observer:CommandObserver in observers) {
			targetScope.messageReceivers.removeCommandObserver(observer);
		}
	}
	
	
}
}
