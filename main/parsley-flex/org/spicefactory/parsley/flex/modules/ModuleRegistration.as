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
 * @author Jens Halm
 */
public class ModuleRegistration {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleRegistration);
	
	
	private var _info:IModuleInfo;
	private var _moduleContext:Context;

	private var _parentContext:Context;
	private var _moduleDomain:ApplicationDomain;
	
	private var _modules:Dictionary = new Dictionary();

	
	function ModuleRegistration (info:IModuleInfo, parentContext:Context = null, moduleDomain:ApplicationDomain = null) {
		this._info = info;
		this._parentContext = parentContext;
		this._moduleDomain = moduleDomain;
		info.addEventListener(ModuleEvent.UNLOAD, onModuleUnloaded);
	}


	public function get info () : IModuleInfo {
		return _info; 	
	}

	public function get active () : Boolean {
		return (_moduleContext != null);
	}
	
	
	public function get parentContext () : Context {
		return _parentContext;
	}
	
	public function get moduleDomain () : ApplicationDomain {
		return _moduleDomain;
	}
	
	/**
	 * @private
	 */
	internal function setModuleDomain (domain:ApplicationDomain) : void {
		_moduleDomain = domain;
	}

	public function addModule (module:Module) : void {
		if (_moduleDomain == null) {
			log.error("Module with URL {0} was already loaded before registering - unable to determine ApplicationDomain."
						+ " No Context will be created.", _info.url);
			return;
		}
		if (_moduleContext == null) {
			// only build context for the first Module instance created from a loaded module
			_moduleContext = module.buildContext(_parentContext, _moduleDomain);
		}
		if (module.viewTriggerEvent != null) {
			if (_modules[module] != undefined) {
				log.error("Module with URL {0}: Attempt to add the same Module instance more than once.", _info.url);
				return;
			}
			_modules[module] = true;
			// view manager must be created for each Module instance
			var viewManager:ModuleViewManager = new ModuleViewManager(module, module.viewTriggerEvent);
			viewManager.init(_moduleContext, _moduleDomain);
		}
	}
	
	
	private function onModuleUnloaded (event:ModuleEvent) : void {
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
