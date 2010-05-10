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

package org.spicefactory.parsley.processor.messaging.receiver {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;
import org.spicefactory.parsley.processor.messaging.MessageReceiverFactory;
import org.spicefactory.parsley.processor.util.MessageReceiverFactories;

/**
 * A message target where a property value of matching messages is bound to a property of the target instance. 
 *  
 * @author Jens Halm
 */
public class MessageBinding extends AbstractObjectProviderReceiver implements MessageTarget {
	
	
	private var targetProperty:Property;
	private var messageProperty:Property;
	
	
	/**
	 * Creates a new instance. 
	 * 
	 * @param provider the provider for the instance that contains the target property
	 * @param targetPropertyName the name of the target property that should be bound
	 * @param messageType the type of the message
	 * @param messagePropertyName the name of the property of the message that should be bound to the target property
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param order the execution order for this receiver
	 */
	function MessageBinding (provider:ObjectProvider, targetPropertyName:String, 
			messageType:ClassInfo, messagePropertyName:String, selector:* = undefined, order:int = int.MAX_VALUE) {
		super(provider, messageType.getClass(), selector, order);
		targetProperty = targetType.getProperty(targetPropertyName);
		if (targetProperty == null) {
			throw new ContextError("Target type " + targetType.name 
					+ " does not contain a property with name " + targetProperty);	
		}
		else if (!targetProperty.writable) {
			throw new ContextError("Target " + targetProperty + " is not writable");
		}
		messageProperty = messageType.getProperty(messagePropertyName);
		if (messageProperty == null) {
			throw new ContextError("Message type " + messageType.name 
					+ " does not contain a property with name " + messageProperty);	
		}
		else if (!messageProperty.readable) {
			throw new ContextError("Message " + messageProperty + " is not readable");
		}		
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function handleMessage (message:Object) : void {
		var value:* = messageProperty.getValue(message);
		targetProperty.setValue(targetInstance, value);
	}
	
	
	/**
	 * Creates a new factory that creates MessageBinding instances. 
	 * Such a factory can be used for convenient registration of a <code>MessageReceiverProcessorFactory</code>
	 * with a target <code>ObjectDefinition</code>.
	 * 
	 * @param targetPropertyName the name of the target property that should be bound
	 * @param messageType the type of the message
	 * @param messagePropertyName the name of the property of the message that should be bound to the target property
	 * @param selector an optional selector value to be used for selecting matching message targets
	 * @param order the execution order for this receiver
	 * @return a new factory that creates MessageBinding instance
	 */
	public static function newFactory (targetPropertyName:String, messageType:ClassInfo, 
			messagePropertyName:String, selector:* = undefined, order:int = int.MAX_VALUE) : MessageReceiverFactory {
				
		return MessageReceiverFactories.newFactory(MessageBinding, 
				[targetPropertyName, messageType, messagePropertyName, selector, order]);
	}
	
	
}
}
