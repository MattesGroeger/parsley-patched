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

import flash.events.Event;

/**
 * MXML tag for declaring the most common setting globally or for a particular Context. 
 * The tag can be used as a child tag of the ContextBuilder tag:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:Settings stageBoundLifecycle="false" autowireViews="true" undhandledMessageErrors="{ErrorPolicy.RETHROW}"/&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlConfig file="logging.xml"/&gt;
 * &lt;/parsley:CompositeContext&gt;</code></pre> 
 * 
 * @author Jens Halm
 */

public class SettingsTag implements ContextBuilderProcessor {
	
	
	private static const CUSTOM_REMOVED_EVENT:String = "removeView";
	
	
	/**
	 * Indicates whether components should only be wired to the Context
	 * as long as they are placed on the stage. The default value is true.
	 * When set to false the component must dispatch a custom "removeView" 
	 * event type to signal that it wishes to be removed from the Context.
	 * When set to true the removedFromStage event will be used instead.
	 * The framework will ignore intermediate stage events caused
	 * by LayoutManagers performing some kind of reparenting to make it 
	 * more robust. 
	 */
	public var stageBoundLifecycle:Boolean = true;
	
	/**
	 * Indicates whether view components will be automatically wired to the
	 * Context. The default value is false. If set to true the only requirement
	 * for a view to get wired is that a corresponding %lt;View&gt; tag is added
	 * to the MXML or XML configuration. When set to false the component must explicitly
	 * signal that it wishes to get wired to the Context through dispatching a "configureView"
	 * event of adding a &lt;parsley:Configure/&gt; tag.
	 */
	public var autowireViews:Boolean = false;
	
	/**
	 * A handler that gets invoked for each Error thrown in any message receiver
	 * in any Context in any scope. The signature of the function must be:
	 * <code>function (processor:MessageProcessor, error:Error) : void</code>
	 */
	public var globalErrorHandler:Function;
	
	/**
	 * The policy to apply for unhandled errors. An unhandled error
	 * is an error thrown by a message handler where no matching error handler
	 * was registered for. The default is <code>ErrorPolicy.IGNORE</code>.
	 */
	public var unhandledMessageErrors:ErrorPolicy;
	
	/**
	 * Indicates whether the settings in this tag should only applied
	 * to the Context built by the corresponding ContextBuilder tag.
	 * If set to false (the default) these settings will be applied globally,
	 * but not to Context instances that were already built.
	 */
	public var local:Boolean = false;
	
	
	/**
	 * @private
	 */
	public function processBuilder (builder:CompositeContextBuilder) : void {
		var registry:FactoryRegistry = (local) ? builder.factories : GlobalFactoryRegistry.instance;
		var eventType:String = (stageBoundLifecycle) ? Event.REMOVED_FROM_STAGE : CUSTOM_REMOVED_EVENT;
		registry.viewManager.componentRemovedEvent = eventType;
		registry.viewManager.viewRootRemovedEvent = eventType;
		registry.viewManager.autowireFilter.enabled = autowireViews;
		if (unhandledMessageErrors != null) {
			registry.messageRouter.unhandledError = unhandledMessageErrors;
		}
		if (globalErrorHandler != null) {
			registry.messageRouter.addErrorHandler(new GlobalMessageErrorHandler(globalErrorHandler));
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

