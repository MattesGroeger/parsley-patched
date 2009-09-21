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
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.impl.DefaultMessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.impl.Providers;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scopes.ScopeName;

[Metadata(name="MessageError", types="method", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods that want to handle errors that were thrown
 * by a message target or interceptor.
 * 
 * <p>This <code>ObjectDefinitionDecorator</code> adds itself to the processed definiton as an <code>ObjectLifecycleListener</code>,
 * thus both interfaces are implemented.</p>
 *
 * @author Jens Halm
 */
public class MessageErrorHandlerDecorator extends AbstractMessageReceiverDecorator implements ObjectDefinitionDecorator {


	/**
	 * The type of the message to handle errors for.
	 */
	public var type:Class;

	/**
	 * @copy org.spicefactory.parsley.messaging.decorator.MessageHandlerDecorator#selector
	 */
	public var selector:String;
	
	/**
	 * The scope this error handler wants to be applied to.
	 * The default is ScopeName.GLOBAL.
	 */
	public var scope:String = ScopeName.GLOBAL;
	
	[Target]
	/**
	 * The name of the error handler method.
	 */
	public var method:String;
	
	/**
	 * The type of the error that this handler is interested in.
	 * The default is the top level Error class.
	 */
	public var errorType:Class = Error;
	
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		domain = registry.domain;
		definition.objectLifecycle.addListener(ObjectLifecycle.POST_INIT, postInit);
		definition.objectLifecycle.addListener(ObjectLifecycle.PRE_DESTROY, preDestroy); 	
		return definition;
	}

	/**
	 * @inheritDoc
	 */
	public function postInit (instance:Object, context:Context) : void {
		var handler:MessageErrorHandler = 
				new DefaultMessageErrorHandler(Providers.forInstance(instance, domain), 
				method, type, selector, errorType);
		context.scopeManager.getScope(scope).messageReceivers.addErrorHandler(handler);
		addReceiver(instance, handler);
	}
	
	/**
	 * @copy org.spicefactory.parsley.factory.ObjectLifecycleListener#preDestroy()
	 */
	public function preDestroy (instance:Object, context:Context) : void {
		context.scopeManager.getScope(scope).messageReceivers.removeErrorHandler(MessageErrorHandler(removeReceiver(instance)));
	}
	
	
}

}
