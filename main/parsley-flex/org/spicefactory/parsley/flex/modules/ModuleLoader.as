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
import org.spicefactory.parsley.flex.modules.ModuleManager;
import org.spicefactory.parsley.flex.modules.ModuleRegistration;

import flash.display.DisplayObject;
import flash.utils.ByteArray;	
import mx.modules.ModuleLoader;

/**
 * @author Jens Halm
 */
public class ModuleLoader extends mx.modules.ModuleLoader {
	
	
	private static const log:Logger = LogContext.getLogger(org.spicefactory.parsley.flex.modules.ModuleLoader);

	/**
	 * The Context to use as a parent for the Module Context.
	 */
	public var parentContext:Context;
	
	private var registration:ModuleRegistration;
	
	
	/**
	 * @private
	 */
	public override function loadModule (url:String = null, bytes:ByteArray = null) : void {
		url = (url != null) ? url : this.url;
		if (url == null) {
			return;
		}
		registration = ModuleManager.getInstance().registerModule(url, parentContext, applicationDomain);
		if (registration.moduleDomain != applicationDomain) {
			/* may happen if the domain was not explicitly set or if it was different from a domain
			 * set by another loader - we have to adjust since there is no way to switch the domain
			 * for a module that has already started to load.
			 */
			applicationDomain = registration.moduleDomain;
		}
		super.loadModule(url, bytes);
	}
	
	/**
	 * @private
	 */
	public override function addChild (child:DisplayObject) : DisplayObject {
		if (!(child is ContextModule)) {
			log.warn("Child created for ModuleLoader with URL {0} does not extend the Parsley Module class", url);
			return super.addChild(child);
		}
		else {
			/*		
			 * First we have to create the ViewManager since super.addChild will trigger
			 * addedToStage events which in turn will trigger configureIOC events.
			 * At that time the ViewManager must already be active even if the Context 
			 * has not been created yet
			 */
			registration.createViewManager(ContextModule(child)); 
			var result:DisplayObject = super.addChild(child);
			/*
			 * In contrast the Context for the Module has to be created after super.addChild
			 * since addChild will also trigger the initialize method which in turn will execute
			 * the bindings. We need those bindings because you can specify the Context container
			 * class as a property on the ContextModule.
			 */
			registration.createContext(ContextModule(child));
			return result;
		}
	}
	
	
}

}
