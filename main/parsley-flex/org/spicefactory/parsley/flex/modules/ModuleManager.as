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

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Manages Parsley ContextModules, usually not used by application code.
 * 
 * @author Jens Halm
 */
public class ModuleManager {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleManager);
	
	
	private static var instance:ModuleManager = new ModuleManager();

	/**
	 * Returns the singleton manager instance.
	 * 
	 * @return the singleton manager instance
	 */
	public static function getInstance () : ModuleManager {
		return instance;
	}


	private var registrations:Dictionary = new Dictionary();

	/**
	 * Registers a Flex Module to be managed by Parsley.
	 * 
	 * @param url the URL of the Module.
	 * @param parentContext the Context to use as the parent for the Context created for the loaded Flex Module
	 * @param moduleDomain the ApplicationDomain the Module will be loaded into
	 * @return a registration instance for the Module
	 */
	public function registerModule (url:String, parentContext:Context = null, moduleDomain:ApplicationDomain = null) : ModuleRegistration {
		var reg:ModuleRegistration = registrations[url]	as ModuleRegistration;
		var info:IModuleInfo = mx.modules.ModuleManager.getModule(url);
		if (reg == null) {
			reg = new ModuleRegistration(info);
			registrations[url] = reg;
		}
		if (!reg.active) {
			log.info("Initialize ModuleRegistration for Module with URL {0}", url);
			if (info.loaded) {
				log.error("Module with URL {0} was already loaded before registering - unable to determine ApplicationDomain.", url);
				moduleDomain = null;
			}
			else if (moduleDomain == null) {
				// must explicitly create domain instance here, we would not have access to it afterwards
				moduleDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			if (parentContext == null) {
				log.warn("Parent context not specified for module with URL {0}", url);
			}
			reg.init(parentContext, moduleDomain);
		}
		else {
			log.info("Module with URL {0} has already been loaded, reusing existing ModuleContext", url);
			/*
			if (reg.moduleDomain == null && !reg.info.loaded) {
				// Could not register domain when initial registration was created.
				if (moduleDomain == null) {
					// must explicitly create domain instance here, we would not have access to it afterwards
					moduleDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
				}
				reg.setModuleDomain(moduleDomain);
			}
			*/
			if (moduleDomain != null && moduleDomain != reg.moduleDomain) {
				log.warn("Module with URL {0} has already been registered with a different ApplicationDomain." 
						+ " The existing registration instance will be returned.", url);
			}
			if (parentContext != null) {
				if (reg.parentContext == null) {
					log.warn("Module Context for module with URL {0} has already been created without a parent Context." 
							+ " The existing registration instance will be returned.", url);
				}
				else if (reg.parentContext != parentContext) {
					log.warn("Module Context for module with URL {0} has already been created with a different parent Context." 
							+ " The existing registration instance will be returned.", url);
				}
			}
		}
		return reg;
	}
	

}
}

