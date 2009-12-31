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
import org.spicefactory.parsley.core.context.provider.SynchronizedObjectProvider;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultMessageInterceptor;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;

[Metadata(name="MessageInterceptor", types="method", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods that want to intercept messages of a particular type
 * dispatched through Parsleys central message router.
 * 
 * @author Jens Halm
 */
public class MessageInterceptorDecorator extends AbstractMessageReceiverDecorator implements ObjectDefinitionDecorator {


	[Target]
	/**
	 * The name of the interceptor method.
	 */
	public var method:String;
	
	/**
	 * @private
	 */
	protected override function handleProvider (provider:SynchronizedObjectProvider) : void {
		var interceptor:MessageInterceptor = new DefaultMessageInterceptor(provider, method, type, selector, order);
		provider.addDestroyHandler(removeInterceptor, interceptor);
		targetScope.messageReceivers.addInterceptor(interceptor);
	}
	
	private function removeInterceptor (interceptor:MessageInterceptor) : void {
		targetScope.messageReceivers.removeInterceptor(interceptor);
	}
	
	
}

}
