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

package org.spicefactory.parsley.flex.modules {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.flex.FlexContextBuilder;
import mx.modules.Module;

import flash.system.ApplicationDomain;

/**
 * Base class for MXML Modules that can be used instead of the default Flex Module base class
 * to associate a Parsley MXML configuration class with the Flex Module. The associated configuration 
 * will be processed as soon as the Module is loaded and the Context created this way will be automatically
 * destroyed when the Flex Module gets unloaded.
 * 
 * <p>If the Context creation for the Module requires more than just a single MXML configuration class,
 * the <code>buildContext</code> method can be overridden instead. You can then use any configuration mechanism
 * you would normally use, including asynchronous mechanisms like XML configuration.</p>
 * 
 * @author Jens Halm
 */
public class ContextModule extends Module {
	
	
	private static const log:Logger = LogContext.getLogger(ContextModule);

	
	/**
	 * The class holding the MXML configuration for this Module.
	 */
	public var configClass:Class;
	
	/**
	 * The event type to use to trigger configuration of Flex Components that wish to be wired to the IOC Container.
	 */
	public var viewTriggerEvent:String = "configureIOC";
	
	
	/**
	 * Invoked by the framework after the Flex Module has been loaded and initialized.
	 * The method should return a new Context instance using the specified parent Context and ApplicationDomain.
	 * 
	 * @param parent the Context to use as the parent for the new Context
	 * @param domain the ApplicationDomain to use for reflection
	 * @return a new Context instance, possibly not fully initialized yet
	 */
	public function buildContext (parent:Context, domain:ApplicationDomain) : Context {
		if (configClass == null) {
			log.warn("No configurationClass specified - skipping context creation");
			return null;
		}
		return FlexContextBuilder.build(configClass, parent, domain, viewTriggerEvent); 
	}
	
	
}
}
