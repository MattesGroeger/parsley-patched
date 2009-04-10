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

import mx.modules.ModuleLoader;

import flash.display.DisplayObject;
import flash.utils.ByteArray;

/**
 * @author Jens Halm
 */
public class ModuleLoader extends mx.modules.ModuleLoader {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleLoader);

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
		if (!(child is Module)) {
			log.warn("Child created for ModuleLoader with URL " + url + " does not extend the Parsley Module class");
			return null;
		}
		registration.addModule(Module(child));
		return super.addChild(child);
	}
	
	
}

}
