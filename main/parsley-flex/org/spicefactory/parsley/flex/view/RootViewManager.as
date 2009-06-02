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

package org.spicefactory.parsley.flex.view {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.util.ClassUtil;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.registry.impl.DefaultObjectDefinitionRegistry;

import mx.core.Application;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * The ViewManager that listens for configuration events on the Flex SystemManager and wires components
 * to the Parsley Context.
 * 
 * @author Jens Halm
 */
public class RootViewManager extends AbstractViewManager {
	
	
	private static const log:Logger = LogContext.getLogger(RootViewManager);
	
	
	private static const managersByTrigger:Dictionary = new Dictionary();
	
	
	/**
	 * Adds the specified Context to be managed by this ViewManager, allowing it
	 * to wire components to the Context based on the ApplicationDomain they live in.
	 * 
	 * @param parent the parent for the Flex ViewContext
	 * @param triggerEvent the event type components will use to signal that they wish to get wired
	 * @param domain the ApplicationDomain of components that will get wired to the specified parent Context
	 */
	public static function addContext (parent:Context, triggerEvent:String = "configureIOC", domain:ApplicationDomain = null) : void {
		log.info("Add Context for trigger event " + triggerEvent);
		if (domain == null) domain = ApplicationDomain.currentDomain;
		var manager:RootViewManager = managersByTrigger[triggerEvent] as RootViewManager;
		if (manager == null) {
			log.info("Create new RootViewManager");
			manager = new RootViewManager();
			managersByTrigger[triggerEvent] = manager;
			manager.init();
		}
		manager.addContext(parent, domain);
	}
	
	
	private const contextsByDomain:Dictionary = new Dictionary();

	/**
	 * @private
	 */	
	function RootViewManager (triggerEventType:String = null) {
		super(triggerEventType);
	}
	
	/**
	 * @private
	 */
	public function init () : void {
		addListener(Application.application.systemManager);
	}
	
	private function addContext (parent:Context, domain:ApplicationDomain) : void {
		if (contextsByDomain[domain] != undefined) {
			if (FlexViewContext(contextsByDomain[domain]).parent != parent) {
				log.warn("Attempt to register the same triggerEvent type {0}"  
						+ " for the same ApplicationDomain for two different Context instances.", triggerEvent);
			}
			return;
		}
		var context:FlexViewContext = new FlexViewContext(parent, new DefaultObjectDefinitionRegistry(domain)); 
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed, false, 2); // must execute before DefaultContext's internal
																			// listener: otherwise context.registry would be null
		contextsByDomain[domain] = context;
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		var context:FlexViewContext = event.target as FlexViewContext;
		delete contextsByDomain[context.registry.domain];
	}

	/**
	 * @private
	 */
	protected override function getContext (component:DisplayObject) : FlexViewContext {
		var domains:Array = new Array();
		for (var domainObj:Object in contextsByDomain) { 
			if (ClassUtil.containsDefintion(domainObj as ApplicationDomain, component)) {
				domains.push(domainObj);
			}
		}
		log.debug("Find ApplicationDomain for component: {0} candidates", domains.length);
		if (domains.length == 0) {
			return null;
		}
		else if (domains.length == 1) {
			return contextsByDomain[domains[0]];
		}
		else {
			for each (var domain:ApplicationDomain in domains) {
				var containsParent:Boolean = false;
				var parent:ApplicationDomain = domain.parentDomain;
				while (parent != null) {
					if (domains.indexOf(parent) != -1) {
						containsParent = true;
						break;					
					}
					parent = parent.parentDomain;
				}
				if (!containsParent) {
					return contextsByDomain[domain];
				}
			}
			// should never get here
			throw new Error("Internal Error while determining ApplicationDomain");
		}
	}
	
	
}

}
