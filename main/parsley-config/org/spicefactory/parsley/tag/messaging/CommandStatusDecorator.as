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
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.processor.core.PropertyProcessor;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.messaging.MessageReceiverProcessorFactory;
import org.spicefactory.parsley.processor.messaging.receiver.CommandStatusFlag;

[Metadata(name="CommandStatus", types="property", multiple="false")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that serve as a flag
 * for indicating whether any matching asynchronous command is currently active.
 * 
 * @author Jens Halm
 */
public class CommandStatusDecorator extends MessageReceiverDecoratorBase implements ObjectDefinitionDecorator {
	
	
	[Target]
	/**
	 * The name of the property that serves as a status flag.
	 */
	public var property:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var messageType:ClassInfo = (type != null) ? ClassInfo.forClass(type, registry.domain) : ClassInfo.forClass(Object);
		var manager:CommandManager = registry.context.scopeManager.getScope(scope).commandManager;

		var factory:MessageReceiverFactory;
		
		factory = CommandStatusFlag.newFactory(property, manager, CommandStatus.EXECUTE, messageType, selector, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		
		factory = CommandStatusFlag.newFactory(property, manager, CommandStatus.COMPLETE, messageType, selector, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		
		factory = CommandStatusFlag.newFactory(property, manager, CommandStatus.ERROR, messageType, selector, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		
		factory = CommandStatusFlag.newFactory(property, manager, CommandStatus.CANCEL, messageType, selector, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));

		var targetProperty:Property = definition.type.getProperty(property);
		definition.addProcessorFactory(PropertyProcessor.newFactory(targetProperty, 
														new CommandStatusValue(manager, messageType.getClass(), selector)));

		return definition;
	}
	
	
}
}

import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.registry.ResolvableValue;

class CommandStatusValue implements ResolvableValue {

	private var manager:CommandManager;
	private var messageType:Class;
	private var selector:*;

	function CommandStatusValue (manager:CommandManager, messageType:Class, selector:*) {
		this.manager = manager;
		this.messageType = messageType;
		this.selector = selector;
	}

	public function resolve (target:ManagedObject) : * {
		return manager.hasActiveCommands(messageType, selector);
	}
	
}
