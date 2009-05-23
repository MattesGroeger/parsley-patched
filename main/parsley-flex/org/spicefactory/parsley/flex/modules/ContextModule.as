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
 * @author Jens Halm
 */
public class ContextModule extends Module {
	
	
	private static const log:Logger = LogContext.getLogger(ContextModule);

	
	public var configurationClass:Class;
	public var viewTriggerEvent:String = "configureIOC";
	
	
	public function buildContext (parent:Context, domain:ApplicationDomain) : Context {
		if (configurationClass == null) {
			log.warn("No configurationClass specified - skipping context creation");
			return null;
		}
		return FlexContextBuilder.build(configurationClass, parent, domain, viewTriggerEvent); 
	}
	
	
}
}