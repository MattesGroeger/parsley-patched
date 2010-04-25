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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.DelayedDelegateChain;
import org.spicefactory.lib.util.Delegate;
import org.spicefactory.lib.util.DelegateChain;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.FastInjectEvent;
import org.spicefactory.parsley.core.events.ViewAutowireEvent;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.registry.ViewDefinition;
import org.spicefactory.parsley.core.registry.ViewDefinitionRegistry;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.view.ViewAutowireMode;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.metadata.RemovedEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/**
 * Default implementation of the ViewManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultViewManager implements ViewManager {


	private static const log:Logger = LogContext.getLogger(DefaultViewManager);
	
	private static const LEGACY_CONFIGURE_EVENT:String = "configureIOC";
	
	private var _viewRootRemovedEvent:String = Event.REMOVED_FROM_STAGE;
	private var _componentRemovedEvent:String = Event.REMOVED_FROM_STAGE;
	private var _componentAddedEvent:String = ViewConfigurationEvent.CONFIGURE_VIEW;

	private var context:Context;
	private var domain:ApplicationDomain;
	private var registry:ViewDefinitionRegistry;
	private var autowireFilter:ViewAutowireFilter;
	private var viewRoots:Array = new Array();
	private var configuredViews:Dictionary = new Dictionary();

	private var cachedFastInjectEvents:Array = new Array();
	
	private var stageEventFilter:StageEventFilter = new StageEventFilter();
	
	private static var prefilteredEvents:Dictionary = new Dictionary();
	private static var prefilterCachePurger:DelegateChain;
	
	private static var uiComponentClass:Class;
	private static var uiComponentClassSet:Boolean;
	private static const globalViewRootRegistry:Dictionary = new Dictionary();
	
	
	private static function setUiComponentClass () : void {
		if (uiComponentClassSet) return;
		uiComponentClassSet = true;
		try {
			uiComponentClass = getDefinitionByName("mx.core.UIComponent") as Class;
		}
		catch (e:Error) {
			/* ignore - we are presumably in a Flash application */
		}
	}

	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the Context view components should be dynamically wired to
	 * @param domain the ApplicationDomain to use for reflection
	 * @param registry the registry for view definitions
	 * @param autowireFilter the filter to select view object applicable for autowiring
	 */
	function DefaultViewManager (context:Context, domain:ApplicationDomain, 
			registry:ViewDefinitionRegistry, autowireFilter:ViewAutowireFilter) {
		this.context = context;
		this.domain = domain;
		this.registry = registry;
		this.autowireFilter = autowireFilter;
	}

	
	private function initialize () : void {
		setUiComponentClass();
		//viewContext = parent.createDynamicContext();
		//context = parent;
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		for each (var view:DisplayObject in viewRoots) {
			handleRemovedViewRoot(view);	
		}
		viewRoots = new Array();
		if (cachedFastInjectEvents.length > 0) {
			context.removeEventListener(ContextEvent.INITIALIZED, handleCachedFastInjectEvents);
			cachedFastInjectEvents = new Array();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function addViewRoot (view:DisplayObject) : void {
		if (viewRoots.indexOf(view) >= 0) return;
		log.info("Add view root: {0}/{1}", view.name, getQualifiedClassName(view));
		if (context == null) initialize();
		if (globalViewRootRegistry[view] != undefined) {
			// we do not allow two view managers on the same view, but we allow switching them
			log.info("Switching ViewManager for view root '{0}'", view);
			var vm:ViewManager = globalViewRootRegistry[view];
			vm.removeViewRoot(view);
		}
		globalViewRootRegistry[view] = this;
		addListeners(view);
		viewRoots.push(view);
	}

	private function viewRootRemoved (event:Event) : void {
		var view:DisplayObject = DisplayObject(event.target);
		if (isRemovable(view)) {
			removeViewRoot(view);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		var index:int = viewRoots.indexOf(view);
		if (index > -1) {
			log.info("Remove view root: {0}/{1}", view.name, getQualifiedClassName(view));
	 		handleRemovedViewRoot(view);
			viewRoots.splice(index, 1);
			if (viewRoots.length == 0) {
				log.info("Last view root removed from ViewManager - Destroy Context");
				context.destroy();
			}
		}
	}
	
	private function addListeners (viewRoot:DisplayObject) : void {
		viewRoot.addEventListener(viewRootRemovedEvent, viewRootRemoved);
		viewRoot.addEventListener(componentAddedEvent, handleConfigurationEvent);
		viewRoot.addEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
		viewRoot.addEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
		viewRoot.addEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
		if (autowireFilter.enabled) {
			viewRoot.addEventListener(autowireFilter.eventType, prefilterView, true);
			viewRoot.addEventListener(autowireFilter.eventType, prefilterView);
			viewRoot.addEventListener(ViewAutowireEvent.AUTOWIRE, handleAutowireEvent);
		}
	}
	
	private function handleRemovedViewRoot (viewRoot:DisplayObject) : void {
	 	viewRoot.removeEventListener(viewRootRemovedEvent, viewRootRemoved);
		viewRoot.removeEventListener(componentAddedEvent, handleConfigurationEvent);
		viewRoot.removeEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
		viewRoot.removeEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
		viewRoot.removeEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
		if (autowireFilter.enabled) {
			viewRoot.removeEventListener(autowireFilter.eventType, prefilterView, true);
			viewRoot.removeEventListener(autowireFilter.eventType, prefilterView);
			viewRoot.removeEventListener(ViewAutowireEvent.AUTOWIRE, handleAutowireEvent);
		}
		delete globalViewRootRegistry[viewRoot];
	}
	
	
	private function contextCreated (event:ContextBuilderEvent) : void {
		if (event.domain == null) {
			event.domain = domain;
		}
		if (event.parent == null) {
			event.parent = context;
		}
		event.stopImmediatePropagation();
	}
	
	
	private function prefilterView (event:Event) : void {
		if (prefilteredEvents[event]) return;
		prefilteredEvents[event] = true;
		if (prefilterCachePurger == null) {
			prefilterCachePurger = new DelayedDelegateChain(1);
			prefilterCachePurger.addDelegate(new Delegate(purgePrefilterCache));
		}
		var view:DisplayObject = event.target as DisplayObject;
		if (autowireFilter.prefilter(view)) {
			view.dispatchEvent(new ViewAutowireEvent());
		}
	}
	
	private function purgePrefilterCache () : void {
		prefilterCachePurger = null;
		prefilteredEvents = new Dictionary();
	}

	protected function handleAutowireEvent (event:Event) : void {
		event.stopImmediatePropagation();
		var view:DisplayObject = event.target as DisplayObject;
		if (configuredViews[view] != undefined) return;
		var mode:ViewAutowireMode = autowireFilter.filter(view);
		if (mode == ViewAutowireMode.ALWAYS) {
			configureView(view, getDefinition(view, view.name));
		}
		else if (mode == ViewAutowireMode.CONFIGURED) {
			var definition:ViewDefinition = getDefinition(view, view.name);
			if (definition != null) {
				configureView(view, definition);
			}
		}
	}

	protected function handleConfigurationEvent (event:Event) : void {
		event.stopImmediatePropagation();
		if (event is ViewConfigurationEvent) {
			ViewConfigurationEvent(event).markAsProcessed();
		}
		var configTarget:Object = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configTarget : event.target;
		var configId:String = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configId 
				: (configTarget is DisplayObject) ? DisplayObject(configTarget).name : null;
		if (configuredViews[configTarget] != undefined) return;
		configureView(configTarget, getDefinition(configTarget, configId));
	}	
	
	protected function configureView (target:Object, definition:ViewDefinition) : void {
		log.debug("Add object '{0}' to {1}", target, context);
		if (target is IEventDispatcher) {
			var info:ClassInfo = ClassInfo.forInstance(target, domain);
			var removedEvent:String = 
					(info.hasMetadata(RemovedEvent)) 
					? (info.getMetadata(RemovedEvent)[0] as RemovedEvent).name
					: componentRemovedEvent; 
			if (removedEvent == Event.REMOVED_FROM_STAGE && target is DisplayObject) {
				stageEventFilter.addTarget(target as DisplayObject, filteredComponentRemoved, filteredComponentAdded);
			}
			else {
				IEventDispatcher(target).addEventListener(removedEvent, componentRemoved);
			}
		}
		var dynObject:DynamicObject = context.addDynamicObject(target, definition);
		configuredViews[target] = dynObject;
	}
	
	protected function getDefinition (configTarget:Object, configId:String) : ViewDefinition {
		var definition:ViewDefinition;
		if (configId != null) {
			definition = registry.getDefinitionById(configId, configTarget);
		}
		if (definition == null) {
			definition = registry.getDefinitionByType(configTarget);
		}
		return definition;
	}

	private function componentRemoved (event:Event) : void {
		var view:IEventDispatcher = IEventDispatcher(event.target);
		filteredComponentRemoved(view);
	}
	
	private function filteredComponentRemoved (view:IEventDispatcher) : void {
		if (!isRemovable(view)) {
			return;
		}
		log.debug("Remove object '{0}' from {1}", view, context);
		if (componentRemovedEvent == Event.REMOVED_FROM_STAGE && view is DisplayObject) {
			stageEventFilter.removeTarget(view as DisplayObject);
		}
		else {
			view.removeEventListener(componentRemovedEvent, componentRemoved);
		}
		var dynObject:DynamicObject = configuredViews[view];
		if (dynObject == null) return;
		delete configuredViews[view];
		dynObject.remove();
	}
	
	private function filteredComponentAdded (view:IEventDispatcher) : void {
		/* do nothing */
	}
	
	
	private function handleFastInject (event:FastInjectEvent) : void {
		event.stopImmediatePropagation();
		if (context.destroyed) return;
		event.markAsProcessed();
		if (!context.initialized) {
			if (cachedFastInjectEvents.length == 0) {
				context.addEventListener(ContextEvent.INITIALIZED, handleCachedFastInjectEvents);
			}
			cachedFastInjectEvents.push(event);
			return;
		}
		processFastInject(event);
	}
	
	private function handleCachedFastInjectEvents (event:ContextEvent) : void {
		for each (var fastInject:FastInjectEvent in cachedFastInjectEvents) {
			processFastInject(fastInject);
		}
		cachedFastInjectEvents = new Array();
	}

	private function processFastInject (event:FastInjectEvent) : void {
		var injections:Array = event.injections;
		for each (var injection:ViewInjection in injections) {
			var target:Object = event.target;
			if ((!injection.objectId && !injection.type) || (injection.objectId && injection.type)) {
				throw new ContextError("Exactly one attribute of type or objectId must be specified");
			}
			var object:Object = (injection.objectId != null)
					? context.getObject(injection.objectId)
					: context.getObjectByType(injection.type);
			target[injection.property] = object;
		}
	}
	
	
	/**
	 * Checks whether the specified view object can be removed.
	 * Will be invoked for view roots and components.
	 * The method should check if the removal should be performed
	 * based on the state of the specified view instance.
	 * For Flex components for example it should check whether 
	 * they have been fully intialized yet. In case the component
	 * dispatches a premature removedFromStage, which often happens
	 * if it is placed within popups or scroll panes, this method
	 * should return false.
	 * 
	 * @param view the view for which to check whether it can be removed
	 * @return true if the specified view can be removed
	 */
	protected function isRemovable (view:Object) : Boolean {
		return (uiComponentClass == null || !(view is uiComponentClass) || view.initialized);
	}
	
	
	/**
	 * @copy org.spicefactory.parsley.core.factory.ViewManagerFactory#viewRootRemovedEvent
	 */
	public function get viewRootRemovedEvent () : String {
		return _viewRootRemovedEvent;
	}
	
	public function set viewRootRemovedEvent (viewRootRemovedEvent:String) : void {
		_viewRootRemovedEvent = viewRootRemovedEvent;
	}
	
	/**
	 * @copy org.spicefactory.parsley.core.factory.ViewManagerFactory#componentRemovedEvent
	 */
	public function get componentRemovedEvent () : String {
		return _componentRemovedEvent;
	}
	
	public function set componentRemovedEvent (componentRemovedEvent:String) : void {
		_componentRemovedEvent = componentRemovedEvent;
	}
	
	/**
	 * @copy org.spicefactory.parsley.core.factory.ViewManagerFactory#componentAddedEvent
	 */
	public function get componentAddedEvent () : String {
		return _componentAddedEvent;
	}
	
	public function set componentAddedEvent (componentAddedEvent:String) : void {
		_componentAddedEvent = componentAddedEvent;
	}
	
	
}
}
