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
import org.spicefactory.parsley.core.context.provider.ObjectProvider;

/**
 * Abstract base class for all types of message receivers that use an ObjectProvider for determining
 * the target instance handling the message.
 * An object provider is a convenient way to register lazy intializing message receivers where
 * the instantiation of the actual instance handling the message may be deferred until the first
 * matching message is dispatched. 
 * 
 * @author Jens Halm
 */
public class AbstractObjectProviderReceiver extends AbstractMessageReceiver {
	
	
	private var provider:ObjectProvider;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param provider the provider for the actual instance handling the message
	 * @param messageType the type of the message this receiver is interested in
	 * @param selector an additional selector value to be used to determine matching messages
	 * @param order the execution order for this receiver
	 */
	function AbstractObjectProviderReceiver (provider:ObjectProvider, 
			messageType:Class = null, selector:* = undefined, order:int = int.MAX_VALUE) {
		super(messageType, selector, order);
		this.provider = provider;
	}

	/**
	 * The target instance that handles the messages.
	 * Accessing this property may lead to initialization of the target instance in case
	 * it is lazy-intializing.
	 */
	protected function get targetInstance () : Object {
		return provider.instance;
	}
	
	/**
	 * The type of the instance handling the messages.
	 */
	protected function get targetType () : ClassInfo {
		return provider.type;
	}
	
	
}
}