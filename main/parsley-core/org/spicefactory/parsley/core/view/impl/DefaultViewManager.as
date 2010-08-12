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

package org.spicefactory.parsley.core.view.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.ViewHandler;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.util.StageEventFilter;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

/**
 * Default implementation of the ViewManager interface.
 * Delegates most of the work to ViewHandlers.
 * 
 * @author Jens Halm
 */
public class DefaultViewManager implements ViewManager {


	private static const log:Logger = LogContext.getLogger(DefaultViewManager);
	
	private var customRemovedEvent:String = "removeView";

	private var context:Context;
	private var domain:ApplicationDomain;
	
	private var settings:ViewSettings;
	
	private var handlers:Array;
	
	private var viewRoots:Dictionary = new Dictionary();
	private var viewRootCount:int = 0;
	
	private var configurator:ViewConfigurator;

	private var stageEventFilter:StageEventFilter = new StageEventFilter();
	
	
	private static const globalViewRootRegistry:Dictionary = new Dictionary();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the Context view components should be dynamically wired to
	 * @param domain the ApplicationDomain to use for reflection
	 * @param settings the settings this ViewManager should use
	 * @param defaultHandlers the ViewHandler implementations covering builtin features
	 */
	function DefaultViewManager (context:Context, domain:ApplicationDomain, settings:ViewSettings, defaultHandlers:Array) {
		this.context = context;
		this.domain = domain;
		this.settings = settings;
		this.configurator = new DefaultViewConfigurator(context, domain, settings);
		this.handlers = new Array();
		initViewHandlers(defaultHandlers);
		initViewHandlers(settings.viewHandlers);
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	private function initViewHandlers (classes:Array) : void {
		for each (var handlerClass:Class in classes) {
			var handler:ViewHandler = new handlerClass();
			handler.init(context, settings, configurator);
			handlers.push(handler);
		}
	}

	private function contextDestroyed (event:ContextEvent) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		for each (var view:ViewRoot in viewRoots) {
			handleRemovedViewRoot(view);	
		}
		viewRoots = new Dictionary();
		viewRootCount = 0;
		for each (var handler:ViewHandler in handlers) {
			handler.destroy();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addViewRoot (view:DisplayObject) : void {
		if (viewRoots[view]) return;
		log.info("Add view root: {0}/{1}", view.name, getQualifiedClassName(view));
		if (globalViewRootRegistry[view] != undefined) {
			// we do not allow two view managers on the same view, but we allow switching them
			log.info("Switching ViewManager for view root '{0}'", view);
			var vm:ViewManager = globalViewRootRegistry[view];
			vm.removeViewRoot(view);
		}
		globalViewRootRegistry[view] = this;
		
		var autoremove:Boolean = configurator.isAutoremove(view, settings.autoremoveViewRoots);
		if (autoremove) {
			stageEventFilter.addTarget(view, filteredViewRootRemoved, ignoredFilteredAddedToStage);
		}
		else {
			view.addEventListener(customRemovedEvent, viewRootRemoved);
		}
		
		viewRoots[view] = new ViewRoot(view, autoremove);
		viewRootCount++;
		
		for each (var handler:ViewHandler in handlers) {
			handler.addViewRoot(view);
		}
	}

	private function viewRootRemoved (event:Event) : void {
		var viewRoot:DisplayObject = DisplayObject(event.target);
		removeViewRoot(viewRoot);
	}
	
	private function filteredViewRootRemoved (viewRoot:DisplayObject) : void {
		removeViewRoot(viewRoot);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		var viewRoot:ViewRoot = viewRoots[view];
		if (viewRoot) {
			log.info("Remove view root: {0}/{1}", viewRoot.view.name, getQualifiedClassName(viewRoot.view));
	 		handleRemovedViewRoot(viewRoot);
			delete viewRoots[view];
			viewRootCount--;
			if (viewRootCount == 0) {
				log.info("Last view root removed from ViewManager - Destroy Context");
				context.destroy();
			}
		}
	}
	
	private function handleRemovedViewRoot (viewRoot:ViewRoot) : void {
		for each (var handler:ViewHandler in handlers) {
			handler.removeViewRoot(viewRoot.view);
		}
			
		if (viewRoot.autoremove) {
			stageEventFilter.removeTarget(viewRoot.view);
		}
		else {
	 		viewRoot.view.removeEventListener(customRemovedEvent, viewRootRemoved);
		}
		delete globalViewRootRegistry[viewRoot.view];
	}
	
	private function ignoredFilteredAddedToStage (view:IEventDispatcher) : void {
		/* do nothing */
	}
}
}

import flash.display.DisplayObject;

class ViewRoot {
	
	public var view:DisplayObject;
	public var autoremove:Boolean;
	
	function ViewRoot (view:DisplayObject, autoremove:Boolean) {
		this.view = view;
		this.autoremove = autoremove;
	}
}
