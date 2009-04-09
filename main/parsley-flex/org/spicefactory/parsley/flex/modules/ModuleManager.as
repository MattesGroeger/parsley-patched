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

	public function registerModule (url:String, parentContext:Context, moduleDomain:ApplicationDomain, builder:ModuleContextBuilder) : void {
		var reg:ModuleRegistration = registrations[url]	as ModuleRegistration;
		if (reg != null) {
			if (reg.parentContext != parentContext && reg.moduleContext != null) {
				log.warn("Module Context for module with URL " + url 
						+ " has already been created with a different parent Context.");
			}
			return;
		}
		var info:IModuleInfo = mx.modules.ModuleManager.getModule(url);
		if (info.ready) {
			log.error("Module with URL " + url 
					+ " was already loaded before registering - unable to determine ApplicationDomain.");
			return;
		}
		reg = new ModuleRegistration(info, parentContext, moduleDomain, builder);
		registrations[url] = reg;
		reg.init();
	}
	
	
}
}

import org.spicefactory.parsley.core.Context;

import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;

import flash.system.ApplicationDomain;

class ModuleRegistration {
	
	
	public var info:IModuleInfo;
	public var parentContext:Context;
	public var moduleContext:Context;
	public var contextBuilder:ModuleContextBuilder;
	public var moduleDomain:ApplicationDomain;

	
	function ModuleRegistration (info:IModuleInfo, parentContext:Context, moduleDomain:ApplicationDomain, builder:ModuleContextBuilder) {
		this.info = info;
		this.parentContext = parentContext;
		this.moduleDomain = moduleDomain;
		this.contextBuilder = builder;
	}

	
	public function init () : void {
		// using low priority here so that the context builder can be initialized first
		info.addEventListener(ModuleEvent.READY, onModuleReady, false, -1);
		info.addEventListener(ModuleEvent.UNLOAD, onModuleUnloaded);
	}
	
	private function onModuleReady (event:ModuleEvent) : void {
		moduleContext = contextBuilder.build(parentContext, moduleDomain);
	}
	
	private function onModuleUnloaded (event:ModuleEvent) : void {
		moduleContext.destroy();
		moduleContext = null;
	}
	
	
}

