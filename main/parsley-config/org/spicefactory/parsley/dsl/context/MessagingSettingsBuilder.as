/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.dsl.context {
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;

/**
 * Builder for messaging settings.
 * 
 * @author Jens Halm
 */
public class MessagingSettingsBuilder implements SetupPart {
	
	
	private var setup:ContextBuilderSetup;
	private var local:Boolean;
	
	private var errorPolicy:ErrorPolicy;
	private var errorHandler:Function;
	
	
	/**
	 * @private
	 */
	function MessagingSettingsBuilder (setup:ContextBuilderSetup, local:Boolean) {
		this.setup = setup;
		this.local = local;
	}

	
	/**
	 * Sets the policy to apply for unhandled errors. An unhandled error
	 * is an error thrown by a message handler where no matching error handler
	 * was registered for. The default is <code>ErrorPolicy.IGNORE</code>.
	 * 
	 * @param policy the policy to apply for unhandled errors
	 * @return the original setup instance for method chaining
	 */	
	public function unhandledError (policy:ErrorPolicy) : ContextBuilderSetup {
		errorPolicy = policy;		
		return setup;
	}
	
	/**
	 * Sets a handler that gets invoked for each Error thrown in any message receiver
	 * in any Context in any scope. The signature of the function must be:
	 * <code>function (processor:MessageProcessor, error:Error) : void</code>
	 * 
	 * @param policy the policy to apply for unhandled errors
	 * @return the original setup instance for method chaining
	 */	
	public function globalErrorHandler (handler:Function) : ContextBuilderSetup {
		errorHandler = handler;	
		return setup;
	}
	
	/**
	 * @private
	 */
	public function apply (builder:CompositeContextBuilder) : void {
		var registry:FactoryRegistry = (local) ? builder.factories : GlobalFactoryRegistry.instance;
		if (errorPolicy != null) {
			registry.messageRouter.unhandledError = errorPolicy;
		}
		if (errorHandler != null) {
			registry.messageRouter.addErrorHandler(new GlobalMessageErrorHandler(globalErrorHandler));
		}
	}
	
	
}
}

import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.processor.messaging.receiver.AbstractMessageReceiver;

class GlobalMessageErrorHandler extends AbstractMessageReceiver implements MessageErrorHandler {


	// TODO - move this helper class to new MessagingSettings class in factory package
	
	private var handler:Function;


	function GlobalMessageErrorHandler (handler:Function) {
		super();
		this.handler = handler;
	}

	public function handleError (processor:MessageProcessor, error:Error) : void {
		handler(processor, error);
	}
	
	public function get errorType () : Class {
		return Error;
	}
	
	
}


