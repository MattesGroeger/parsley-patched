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
import org.spicefactory.parsley.core.context.impl.DynamicContext;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class DefaultViewManager implements ViewManager {


	private static const log:Logger = LogContext.getLogger(DefaultViewManager);
	
	
	private var _viewRootRemovedEvent:String = Event.REMOVED_FROM_STAGE;
	private var _componentRemovedEvent:String = Event.REMOVED_FROM_STAGE;
	private var _componentAddedEvent:String = ViewConfigurationEvent.CONFIGURE_VIEW;

	private var viewRoots:Array = new Array();
	private var viewContext:DynamicContext;
	
	
	function DefaultViewManager (parent:Context, domain:ApplicationDomain, factories:FactoryRegistry, viewRoot:DisplayObject = null) {
		viewContext = new DynamicContext(parent, domain, factories, this);
		viewContext.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		if (viewRoot != null) addViewRoot(viewRoot);
	}

	
	private function contextDestroyed (event:ContextEvent) : void {
		viewContext.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		for each (var view:DisplayObject in viewRoots) {
			removeListeners(view);	
		}
		viewRoots = new Array();
	}
	
	/**
	 * @inheritDoc
	 */
	public function addViewRoot (view:DisplayObject) : void {
		log.info("Add view root: {0}/{1}", view.name, getQualifiedClassName(view));
		addListeners(view);
		viewRoots.push(view);
	}

	private function viewRootRemoved (event:Event) : void {
		removeViewRoot(DisplayObject(event.target));
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		var index:int = viewRoots.indexOf(view);
		if (index > -1) {
			log.info("Remove view root: {0}/{1}", view.name, getQualifiedClassName(view));
	 		removeListeners(view);
			viewRoots.splice(index, 1);
			if (viewRoots.length == 0) {
				log.info("Last view root removed from ViewManager - Destroy Context");
				viewContext.parent.destroy();
			}
		}
	}
	
	private function addListeners (viewRoot:DisplayObject) : void {
		viewRoot.addEventListener(viewRootRemovedEvent, viewRootRemoved);
		viewRoot.addEventListener(componentAddedEvent, componentAdded);
		viewRoot.addEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
	}
	
	private function removeListeners (viewRoot:DisplayObject) : void {
	 	viewRoot.removeEventListener(viewRootRemovedEvent, viewRootRemoved);
		viewRoot.removeEventListener(componentAddedEvent, componentAdded);
		viewRoot.removeEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
	}
	
	
	private function contextCreated (event:ContextBuilderEvent) : void {
		if (event.domain == null) {
			event.domain = viewContext.registry.domain;
		}
		if (event.parent == null) {
			event.parent = viewContext.parent;
		}
		event.stopImmediatePropagation();
	}
	
	
	private function componentAdded (event:Event) : void {
		event.stopImmediatePropagation();
		var component:DisplayObject = DisplayObject(event.target);
		log.debug("Add component '{0}' to view Context", component);
		component.addEventListener(componentRemovedEvent, componentRemoved);
		viewContext.addObject(component);
	}
	
	private function componentRemoved (event:Event) : void {
		var component:DisplayObject = DisplayObject(event.target);
		log.debug("Remove component '{0}' from view Context", component);
		component.removeEventListener(componentRemovedEvent, componentRemoved);
		viewContext.removeObject(component);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get viewRootRemovedEvent () : String {
		return _viewRootRemovedEvent;
	}
	
	public function set viewRootRemovedEvent (viewRootRemovedEvent:String) : void {
		_viewRootRemovedEvent = viewRootRemovedEvent;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get componentRemovedEvent () : String {
		return _componentRemovedEvent;
	}
	
	public function set componentRemovedEvent (componentRemovedEvent:String) : void {
		_componentRemovedEvent = componentRemovedEvent;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get componentAddedEvent () : String {
		return _componentAddedEvent;
	}
	
	public function set componentAddedEvent (componentAddedEvent:String) : void {
		_componentAddedEvent = componentAddedEvent;
	}
	
	
}
}
