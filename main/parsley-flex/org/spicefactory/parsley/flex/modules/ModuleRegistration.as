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
import org.spicefactory.parsley.flex.view.ModuleViewManager;

import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;	

/**
 * Represents the registration of a single Flex Module managed by Parsley.
 * 
 * @author Jens Halm
 */
public class ModuleRegistration {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleRegistration);
	
	
	private var _info:IModuleInfo;
	private var _moduleContext:Context;

	private var _parentContext:Context;
	private var _moduleDomain:ApplicationDomain;
	
	private var _modules:Dictionary = new Dictionary();

	
	/**
	 * Creates a new instance.
	 * 
	 * @param info the regular Flex Module Info
	 * @param parentContext the Context to use as the parent for the Context created for the loaded Flex Module
	 * @param moduleDomain the ApplicationDomain the Module will be loaded into
	 */
	function ModuleRegistration (info:IModuleInfo, parentContext:Context = null, moduleDomain:ApplicationDomain = null) {
		this._info = info;
		this._parentContext = parentContext;
		this._moduleDomain = moduleDomain;
		info.addEventListener(ModuleEvent.UNLOAD, onModuleUnloaded);
	}


	/**
	 * The Flex Module Info for this managed Module.
	 */
	public function get info () : IModuleInfo {
		return _info; 	
	}

	/**
	 * Indicates whether the Parsley Context for the Flex Module has already been created.
	 */
	public function get active () : Boolean {
		return (_moduleContext != null);
	}
	
	/**
	 * The Context to use as the parent for the Context created for the loaded Flex Module.
	 */
	public function get parentContext () : Context {
		return _parentContext;
	}
	
	/**
	 * The ApplicationDomain the Module will be loaded into.
	 */
	public function get moduleDomain () : ApplicationDomain {
		return _moduleDomain;
	}
	
	/**
	 * @private
	 */
	internal function setModuleDomain (domain:ApplicationDomain) : void {
		_moduleDomain = domain;
	}
	
	private function checkModuleDomain () : void {
		if (_moduleDomain == null) {
			log.error("Module with URL {0} was already loaded before registering - unable to determine ApplicationDomain."
						+ " No Context will be created.", _info.url);
			return;
		}		
	}

	/**
	 * Creates the view manager for the specified Module.
	 * This method will register a listener for the root module class that will be used
	 * for the module in addition to the listener registered for the Flex SystemManager.
	 * 
	 * @param module the Module to create the view manager for
	 */
	public function createViewManager (module:ContextModule) : void {
		log.info("Create ViewManager for {0}", module);
		checkModuleDomain();
		if (module.viewTriggerEvent != null) {
			if (_modules[module] != undefined) {
				log.error("Module with URL {0}: Attempt to add the same Module instance more than once.", _info.url);
				return;
			}
			// view manager must be created for each Module instance
			var viewManager:ModuleViewManager = new ModuleViewManager(module, module.viewTriggerEvent);
			_modules[module] = viewManager;
			if (_moduleContext != null) {
				viewManager.init(_moduleContext, _moduleDomain);
			}
		}
	}
	
	/**
	 * Creates the Parsley Context for the specified Module.
	 * This method will do nothing if the Context has already been created for other
	 * Module instances created from the same Flex Module.
	 * 
	 * @param module the Module to create the Parsley Context for
	 */
	public function createContext (module:ContextModule) : void {
		log.info("Create Context for {0}", module);
		checkModuleDomain();
		if (_moduleContext == null) {
			// only build context for the first Module instance created from a loaded module
			_moduleContext = module.buildContext(_parentContext, _moduleDomain);
			var viewManager:ModuleViewManager = _modules[module] as ModuleViewManager;
			if (viewManager == null) {
				log.error("No ViewManager available for Module {0}", module);
			}
			viewManager.init(_moduleContext, _moduleDomain);
		}
	}
	
	
	private function onModuleUnloaded (event:ModuleEvent) : void {
		log.info("Unload Module '{0}'", event.module.url);
		if (_moduleContext != null) {
			_moduleContext.destroy();
		}
		_moduleContext = null;
		_moduleDomain = null;
		_parentContext = null;
		_modules = new Dictionary();
	}
	

}
}
