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
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.messaging.MessageReceiverProcessorFactory;
import org.spicefactory.parsley.processor.messaging.receiver.DefaultCommandObserver;

/**
 * Abstract base class for methods that wish to be invoked after completion of asynchronous commands.
 * 
 * @author Jens Halm
 */
public class AbstractCommandObserverDecorator extends MessageReceiverDecoratorBase implements ObjectDefinitionDecorator {
	
	
	[Target]
	/**
	 * The name of the method that wishes to handle the message.
	 */
	public var method:String;
	
	
	private var status:CommandStatus;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param status the status this message receiver is interested in
	 */
	function AbstractCommandObserverDecorator (status:CommandStatus) {
		this.status = status;
	}

	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var messageType:ClassInfo = (type != null) ? ClassInfo.forClass(type, registry.domain) : null;
		var factory:MessageReceiverFactory = DefaultCommandObserver.newFactory(method, status, selector, messageType, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		return definition;
	}
	
	
}
}
