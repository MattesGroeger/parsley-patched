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
import mx.modules.ModuleManagerGlobals;

/**
 * @author Jens Halm
 */
public class FlexModuleSupport {
	
	
	private static var initialized:Boolean = false;
	
	
	public static var defaultLoadingPolicy:ModuleLoadingPolicy = ModuleLoadingPolicy.CHILD_DOMAIN;

	
	public static function initialize () : void {
		if (initialized) return;
		initialized = true;
		var originalManager:Object = ModuleManagerGlobals.managerSingleton;
		ModuleManagerGlobals.managerSingleton = new ModuleManagerDecorator(originalManager);
	}
	
	
}
}

import org.spicefactory.parsley.flex.modules.FlexModuleSupport;
import org.spicefactory.parsley.flex.modules.ModuleLoadingPolicy;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;

import mx.core.IFlexModuleFactory;
import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.utils.ByteArray;

class ModuleManagerDecorator {
	
	private var originalManager:Object;
	
	function ModuleManagerDecorator (originalManager:Object) {
		this.originalManager = originalManager;
	}

	public function getAssociatedFactory (object:Object) : IFlexModuleFactory {
		return originalManager.getAssociatedFactory(object); // TODO - this is not our proxied factory
	}
	
	public function getModule (url:String) : IModuleInfo {
		return new ModuleInfoProxy(originalManager.getModule(url));
	}
	
}

class ModuleInfoProxy implements IModuleInfo {
	
	
	private var module:IModuleInfo;
	private var factoryProxy:IFlexModuleFactory;
	private var domain:ApplicationDomain;
	
	
	function ModuleInfoProxy (module:IModuleInfo) {
		this.module = module;
		module.addEventListener(ModuleEvent.UNLOAD, moduleUnloaded);
	}
	
	private function moduleUnloaded (event:Event) : void {
		domain = null;
		factoryProxy = null;
	}

	public function load (applicationDomain:ApplicationDomain = null, 
			securityDomain:SecurityDomain = null, bytes:ByteArray = null) : void {
		if (domain == null) {
			domain = (applicationDomain != null) ? applicationDomain
					: (FlexModuleSupport.defaultLoadingPolicy == ModuleLoadingPolicy.ROOT_DOMAIN) ?
					ClassInfo.currentDomain : new ApplicationDomain(ClassInfo.currentDomain);
		}
		module.load(domain, securityDomain, bytes);
	}
	
	public function get factory () : IFlexModuleFactory {
		if (factoryProxy == null && module.factory != null) {
			factoryProxy = new FlexModuleFactoryProxy(module, domain);
		}
		return factoryProxy;
	}
	
	public function release () : void {
		module.release();
	}
	
	public function publish (factory:IFlexModuleFactory) : void {
		module.publish(factory);
	}
	
	public function unload () : void {
		module.unload();
	}
	
	public function get setup () : Boolean {
		return module.setup;
	}
	
	public function get ready () : Boolean {
		return module.ready;
	}
	
	public function get loaded () : Boolean {
		return module.loaded;
	}
	
	public function get error () : Boolean {
		return module.error;
	}
	
	public function get data () : Object {
		return module.data;
	}
	
	public function set data (value:Object) : void {
		module.data = value;
	}
	
	public function get url () : String {
		return module.url;
	}
	
	
	public function dispatchEvent (event:Event) : Boolean {
		return module.dispatchEvent(event);
	}
	
	public function hasEventListener (type:String) : Boolean {
		return module.hasEventListener(type);
	}
	
	public function willTrigger (type:String) : Boolean {
		return module.willTrigger(type);
	}
	
	public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, 
			priority:int = 0, useWeakReference:Boolean = false) : void {
		module.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void {
		module.removeEventListener(type, listener, useCapture);
	}
	
}

class FlexModuleFactoryProxy implements IFlexModuleFactory {

	private var module:IModuleInfo;
	private var domain:ApplicationDomain;
	
	function FlexModuleFactoryProxy (module:IModuleInfo, domain:ApplicationDomain) {
		this.module = module;
		this.domain = domain;
	}

	public function create (...args:*) : Object {
		var instance:Object = module.factory.create.apply(module.factory, args);
		if (instance is DisplayObject) {
			
		}
		return null;
	}
	
	public function info () : Object {
		return module.factory.info();
	}
	
}

class ContextBuilderEventListener {

	private var view:DisplayObject;
	private var module:IModuleInfo;
	private var domain:ApplicationDomain;

	function ContextBuilderEventListener (view:DisplayObject, module:IModuleInfo, domain:ApplicationDomain) {
		this.view = view;
		this.module = module;
		this.domain = domain;
		view.addEventListener(ContextBuilderEvent.BUILD_CONTEXT, buildContext);	
		module.addEventListener(ModuleEvent.UNLOAD, moduleUnloaded);	
	}
	
	private function moduleUnloaded (event:Event) : void {
		view.removeEventListener(ContextBuilderEvent.BUILD_CONTEXT, buildContext);	
		module.removeEventListener(ModuleEvent.UNLOAD, moduleUnloaded);		
	}
	
	private function buildContext (event:ContextBuilderEvent) : void {
		if (event.domain == null) {
			event.domain = domain;
		}
	}
	
}
