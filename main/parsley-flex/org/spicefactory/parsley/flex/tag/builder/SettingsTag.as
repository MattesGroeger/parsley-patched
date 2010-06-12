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

package org.spicefactory.parsley.flex.tag.builder {
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;

[Deprecated(replacement="ViewSettings and MessageSettings")]
public class SettingsTag implements ContextBuilderProcessor {
	
	public var stageBoundLifecycle:Boolean = true;
	
	public var autowireViews:Boolean = false;
	
	public var globalErrorHandler:Function;
	
	public var unhandledMessageErrors:ErrorPolicy;
	
	public var local:Boolean = false;
	
	public function processBuilder (builder:CompositeContextBuilder) : void {
		var registry:FactoryRegistry = (local) ? builder.factories : GlobalFactoryRegistry.instance;
		registry.viewSettings.autoremoveComponents = stageBoundLifecycle;
		registry.viewSettings.autoremoveViewRoots = stageBoundLifecycle;
		registry.viewSettings.autowireComponents = autowireViews;
		if (unhandledMessageErrors != null) {
			registry.messageSettings.unhandledError = unhandledMessageErrors;
		}
		if (globalErrorHandler != null) {
			registry.messageSettings.addErrorHandler(new GlobalMessageErrorHandler(globalErrorHandler));
		}
	}
}
}

import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.processor.messaging.receiver.AbstractMessageReceiver;

class GlobalMessageErrorHandler extends AbstractMessageReceiver implements MessageErrorHandler {

	
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

