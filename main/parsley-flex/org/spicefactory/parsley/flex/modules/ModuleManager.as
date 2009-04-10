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

import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class ModuleManager {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleManager);
	
	
	private static var instance:ModuleManager = new ModuleManager();

	public static function getInstance () : ModuleManager {
		return instance;
	}


	private var registrations:Dictionary = new Dictionary();

	public function registerModule (url:String, parentContext:Context = null, moduleDomain:ApplicationDomain = null) : ModuleRegistration {
		var reg:ModuleRegistration = registrations[url]	as ModuleRegistration;
		if (reg == null) {
			var info:IModuleInfo = mx.modules.ModuleManager.getModule(url);
			if (info.loaded) {
				log.error("Module with URL " + url 
						+ " was already loaded before registering - unable to determine ApplicationDomain.");
				moduleDomain = null;
			}
			else if (moduleDomain == null) {
				// must explicitly create domain instance here, we would not have access to it afterwards
				moduleDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			if (parentContext == null) {
				log.warn("Parent context not specified for module with URL " + url);
			}
			reg = new ModuleRegistration(info, parentContext, moduleDomain);
			registrations[url] = reg;
		}
		else {
			if (reg.moduleDomain == null && !reg.info.loaded) {
				// Could not register domain when initial registration was created.
				if (moduleDomain == null) {
					// must explicitly create domain instance here, we would not have access to it afterwards
					moduleDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
				}
				reg.setModuleDomain(moduleDomain);
			}
			else if (moduleDomain != null && moduleDomain != reg.moduleDomain) {
				log.warn("Module with URL " + url 
						+ " has already been registered with a different ApplicationDomain." 
						+ " The existing registration instance will be returned.");
			}
			if (parentContext != null) {
				if (reg.parentContext == null) {
					log.warn("Module Context for module with URL " + url 
							+ " has already been created without a parent Context." 
							+ " The existing registration instance will be returned.");
				}
				else if (reg.parentContext != parentContext) {
					log.warn("Module Context for module with URL " + url 
							+ " has already been created with a different parent Context." 
							+ " The existing registration instance will be returned.");
				}
			}
		}
		return reg;
	}
	

}
}
