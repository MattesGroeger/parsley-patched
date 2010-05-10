/*
 * Copyright 2008-2009 the original author or authors.
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
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.messaging.MessageReceiverProcessorFactory;
import org.spicefactory.parsley.processor.messaging.receiver.MessageHandler;

[Metadata(name="MessageHandler", types="method", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods which wish to handle messages
 * dispatched through Parsleys central message router.
 * 
 * @author Jens Halm
 */
public class MessageHandlerDecorator extends MessageReceiverDecoratorBase implements ObjectDefinitionDecorator {


	/**
	 * Optional list of names of properties of the message that should be used as method parameters
	 * instead passing the message itself as a parameter.
	 */
	public var messageProperties:Array;

	[Target]
	/**
	 * The name of the method that wishes to handle the message.
	 */
	public var method:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		if (messageProperties != null && type == null) {
			throw new ContextError("Message type must be specified if messageProperties attribute is used");
		}
		var messageType:ClassInfo = (type != null) ? ClassInfo.forClass(type, registry.domain) : null;
		var factory:MessageReceiverFactory = MessageHandler.newFactory(method, selector, messageType, messageProperties, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		return definition;
	}
	
	
}
}

