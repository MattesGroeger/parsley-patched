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
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;
import org.spicefactory.parsley.core.messaging.receiver.impl.MessageHandler;
import org.spicefactory.parsley.core.messaging.receiver.impl.MessagePropertyHandler;
import org.spicefactory.parsley.core.messaging.receiver.impl.Providers;
import org.spicefactory.parsley.core.messaging.receiver.impl.TargetInstanceProvider;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.definition.ObjectLifecycleListener;

[Metadata(name="MessageHandler", types="method", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods which wish to handle messages
 * dispatched through Parsleys central message router.
 * 
 * <p>This <code>ObjectDefinitionDecorator</code> adds itself to the processed definiton as an <code>ObjectLifecycleListener</code>,
 * thus both interfaces are implemented.</p>
 *
 * @author Jens Halm
 */
public class MessageHandlerDecorator extends AbstractMessageTargetDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {


	/**
	 * The type of the messages the target method wishes to handle.
	 */
	public var type:Class;

	/**
	 * An optional selector value to be used in addition to selecting messages by type.
	 * Will be checked against the value of the property in the message marked with <code>[Selector]</code>
	 * or against the event type if the message is an event and does not have a selector property specified explicitly.
	 */
	public var selector:String;
	
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
		domain = registry.domain;
		definition.lifecycleListeners.addLifecycleListener(this);
		return definition;
	}
	
	/**
	 * @inheritDoc
	 */
	public function postConstruct (instance:Object, context:Context) : void {
		var messageType:ClassInfo = (type != null) ? ClassInfo.forClass(type) : null;
		var provider:TargetInstanceProvider = Providers.forInstance(instance, domain);
		var target:MessageTarget;
		if (messageProperties != null) {
			target = new MessagePropertyHandler(provider, method, messageType, messageProperties, selector);
		}
		else {
			target = new MessageHandler(provider, method, selector, messageType);
		}
		context.messageRouter.addTarget(target);
		addTarget(instance, target);
	}
	
	/**
	 * @copy org.spicefactory.parsley.factory.ObjectLifecycleListener#preDestroy()
	 */
	public function preDestroy (instance:Object, context:Context) : void {
		context.messageRouter.removeTarget(MessageTarget(removeTarget(instance)));
	}
	
	
}
}

