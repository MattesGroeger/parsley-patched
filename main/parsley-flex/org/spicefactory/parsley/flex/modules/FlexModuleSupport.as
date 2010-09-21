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
import mx.modules.ModuleManager;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

import mx.modules.ModuleManagerGlobals;

/**
 * Provides support for seamless integration of Flex Modules into modular Parsley applications.
 * The primary task for this support is to transparently provide the
 * information which ApplicationDomain a module was loaded into to ContextBuilder instances
 * within that module. For this purpose the Flex ModuleManager will be replaced by a special
 * Parsley variant that wraps additional functionality around the builtin ModuleManager.
 * 
 * @author Jens Halm
 */
public class FlexModuleSupport {
	
	
	private static const log:Logger = LogContext.getLogger(FlexModuleSupport);
	
	
	private static var initialized:Boolean = false;
	
	/**
	 * The policy into which ApplicationDomain modules should be loaded per default.
	 * Allows to conveniently switch from the Flex SDK default (always loading into child domains)
	 * to a mode where modules are always loaded into the root domain. This way the domain does
	 * not have to be specified for each individual ModuleLoader in case all modules should be loaded
	 * into the root domain.
	 */	
	public static var defaultLoadingPolicy:ModuleLoadingPolicy = ModuleLoadingPolicy.CHILD_DOMAIN;

	/**
	 * Intializes the Flex Module Support. Usually there is no need for application code to call this
	 * method directly. It will be invoked by all static entry points in the <code>FlexContextBuilder</code>
	 * class for example. In rare cases where you only use some other configuration mechanism like XML
	 * for your Flex application it may be necessary to invoke this method manually.
	 */
	public static function initialize () : void {
		if (initialized) return;
		log.info("Initialize Flex Module Support");
		initialized = true;
		ModuleManager.getModule("DoesNotExist.swf"); // trigger the creation of the ModuleManager singleton
		var originalManager:Object = ModuleManagerGlobals.managerSingleton;
		ModuleManagerGlobals.managerSingleton = new ModuleManagerDecorator(originalManager);
	}
}
}

import flash.events.EventDispatcher;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.flex.modules.FlexModuleSupport;
import org.spicefactory.parsley.flex.modules.ModuleLoadingPolicy;

import mx.core.IFlexModuleFactory;
import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

class ModuleManagerDecorator {
	
	private var originalManager:Object;
	private var domainMap:Dictionary = new Dictionary();
	
	function ModuleManagerDecorator (originalManager:Object) {
		this.originalManager = originalManager;
	}

	public function getAssociatedFactory (object:Object) : IFlexModuleFactory {
		return originalManager.getAssociatedFactory(object); // TODO - this is not our proxied factory
	}
	
	public function getModule (url:String) : IModuleInfo {
		var module:IModuleInfo = originalManager.getModule(url);
		if (domainMap[url] == undefined) {
			domainMap[url] = new DomainInfo();
		}
		return new ModuleInfoProxy(module, domainMap[url] as DomainInfo);
	}
	
}

class DomainInfo {
	
	public var current:ApplicationDomain;
	
}

class ModuleInfoBase extends EventDispatcher {
	
	protected function getDomain (applicationDomain:ApplicationDomain) : ApplicationDomain {
		throw new AbstractMethodError();
	}
	protected function getModule () : Object {
		throw new AbstractMethodError();
	}
	protected function setDomain (domain:ApplicationDomain) : void {
		throw new AbstractMethodError();
	}
}

class Flex3ModuleInfoBase extends ModuleInfoBase {
	
	public function load (applicationDomain:ApplicationDomain = null, 
			securityDomain:SecurityDomain = null, bytes:ByteArray = null) : void {
		var domain:ApplicationDomain = getDomain(applicationDomain);
		getModule().load(domain, securityDomain, bytes);
		setDomain(domain);
	}
	
}

class Flex4ModuleInfoBase extends ModuleInfoBase {
	
	public function load (applicationDomain:ApplicationDomain = null, 
			securityDomain:SecurityDomain = null, bytes:ByteArray = null, moduleFactory:IFlexModuleFactory = null) : void {
		var domain:ApplicationDomain = getDomain(applicationDomain);
		getModule().load(domain, securityDomain, bytes, moduleFactory);
		setDomain(domain);
	}
	
}

class ModuleInfoProxy extends Flex3ModuleInfoBase implements IModuleInfo {
	
	
	private static const log:Logger = LogContext.getLogger(FlexModuleSupport);
	
	
	private var module:IModuleInfo;
	private var domain:DomainInfo;
	private var newDomain:Boolean;
	private var factoryProxy:IFlexModuleFactory;
	
	
	function ModuleInfoProxy (module:IModuleInfo, domain:DomainInfo) {
		this.module = module;
		this.domain = domain;
		
		module.addEventListener(ModuleEvent.SETUP, moduleEventHandler, false, 0, true);
        module.addEventListener(ModuleEvent.PROGRESS, moduleEventHandler, false, 0, true);
        module.addEventListener(ModuleEvent.READY, moduleEventHandler, false, 0, true);
        module.addEventListener(ModuleEvent.ERROR, moduleEventHandler, false, 0, true);
        module.addEventListener(ModuleEvent.UNLOAD, moduleEventHandler, false, 0, true);
	}
	
	private function moduleEventHandler (event:ModuleEvent) : void {
        dispatchEvent(event);
    }
	
	private function moduleUnloaded (event:Event) : void {
		var module:IModuleInfo = event.target as IModuleInfo;
		module.removeEventListener(ModuleEvent.UNLOAD, moduleUnloaded);
		log.info("Unload Module with URL " + module.url);
		domain.current = null;
		
		module.removeEventListener(ModuleEvent.SETUP, moduleEventHandler);
        module.removeEventListener(ModuleEvent.PROGRESS, moduleEventHandler);
        module.removeEventListener(ModuleEvent.READY, moduleEventHandler);
        module.removeEventListener(ModuleEvent.ERROR, moduleEventHandler);
        module.removeEventListener(ModuleEvent.UNLOAD, moduleEventHandler);
	}
	
	private function unloadBeforeLoad (event:Event) : void {
		var module:IModuleInfo = event.target as IModuleInfo;
		log.info("Unload before loading Module with URL " + module.url);
		domain.current = null;
		newDomain = true;
	}
	
	protected override function getDomain (applicationDomain:ApplicationDomain) : ApplicationDomain {
		if (loaded) {
			log.info("Module with URL " + module.url + " already loaded");
			module.addEventListener(ModuleEvent.UNLOAD, unloadBeforeLoad);
			return applicationDomain;
		} else {
			log.info("Loading Module with URL " + module.url);
			newDomain = true;
			return (applicationDomain != null) ? applicationDomain
					: (FlexModuleSupport.defaultLoadingPolicy == ModuleLoadingPolicy.ROOT_DOMAIN) ?
					ClassInfo.currentDomain : new ApplicationDomain(ApplicationDomain.currentDomain);
		}
	}
	
	protected override function setDomain (domain:ApplicationDomain) : void {
		module.removeEventListener(ModuleEvent.UNLOAD, unloadBeforeLoad);	
		if (newDomain) {
			newDomain = false;
			this.domain.current = domain;	
			module.addEventListener(ModuleEvent.UNLOAD, moduleUnloaded);
		}
	}
	
	protected override function getModule () : Object {
		return module;
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
	
	
}


class FlexModuleFactoryProxy implements IFlexModuleFactory {

	private var factory:Object; // typed as Object to hide differences between 3.3, 3.4, 4.0 SDKs
	private var module:IModuleInfo;
	private var domain:DomainInfo;
	
	function FlexModuleFactoryProxy (module:IModuleInfo, domain:DomainInfo) {
		this.module = module;
		this.domain = domain;
		this.factory = module.factory;
	}

	public function create (...args:*) : Object {
		var instance:Object = module.factory.create.apply(module.factory, args);
		if (instance is DisplayObject) {
			new ContextBuilderEventListener(instance as DisplayObject, module, domain);
		}
		return instance;
	}
	
	public function info () : Object {
		return module.factory.info();
	}
	
	// added in SDK 3.4
	public function allowInsecureDomain (...args:*) : void {
		factory.allowInsecureDomain.apply(module.factory, args);
	}
	
	// added in SDK 3.4
	public function allowDomain (...args:*) : void {
		factory.allowDomain.apply(module.factory, args);
	}
	
	// added in SDK 3.4
	public function get preloadedRSLs () : Dictionary {
		return factory.preloadedRSLs;
	}
	
	// added in SDK 4.0
	public function callInContext (fn:Function, thisArg:Object, argArray:Array, returns:Boolean = true) : * {
		return factory.callInContext(fn, thisArg, argArray, returns);
	}
	
	// added in SDK 4.0
	public function getImplementation (interfaceName:String) : Object {
		return factory.getImplementation(interfaceName);
	}
	
	// added in SDK 4.0
	public function registerImplementation (interfaceName:String, impl:Object) : void {
		factory.registerImplementation(interfaceName, impl);
	}
	
}

class ContextBuilderEventListener {
	
	private static const log:Logger = LogContext.getLogger(FlexModuleSupport);

	private var view:DisplayObject;
	private var module:IModuleInfo;
	private var domain:DomainInfo;

	function ContextBuilderEventListener (view:DisplayObject, module:IModuleInfo, domain:DomainInfo) {
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
			if (domain.current == null) {
				var msg:String = "Unable to determine ApplicationDomain for Module with url " + module.url 
						+ ". Loading has been triggered before Parsley's Flex Module support has been initialized";
				log.error(msg);
				throw new IllegalStateError(msg); 
			}
			log.info("Passing ApplicationDomain for module " + module.url + " to ContextBuilder Event");
			event.domain = domain.current;
		}
	}
	
}
