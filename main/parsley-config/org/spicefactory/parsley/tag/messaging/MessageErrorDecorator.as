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
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.messaging.MessageReceiverProcessorFactory;
import org.spicefactory.parsley.processor.messaging.receiver.DefaultMessageErrorHandler;

[Metadata(name="MessageError", types="method", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods that want to handle errors that were thrown
 * by a regular message target or an interceptor.
 * 
 * @author Jens Halm
 */
public class MessageErrorDecorator extends MessageReceiverDecoratorBase implements ObjectDefinitionDecorator {

	
	[Target]
	/**
	 * The name of the error handler method.
	 */
	public var method:String;
	
	/**
	 * The type of the error that this handler is interested in.
	 * The default is the top level Error class.
	 */
	public var errorType:Class;

	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var errorTypeInfo:ClassInfo = (errorType != null) ? ClassInfo.forClass(errorType, registry.domain) : null;
		var factory:MessageReceiverFactory = DefaultMessageErrorHandler.newFactory(method, type, selector, errorTypeInfo, order);
		definition.addProcessorFactory(new MessageReceiverProcessorFactory(definition, factory, registry.context, scope));
		return definition;
	}
	
	
}

}
