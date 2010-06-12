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
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.view.ViewAutowireMode;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.metadata.Autoremove;

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
	
	private var customRemovedEvent:String = "removeView";
	private var explicitWireEvent:String = ViewConfigurationEvent.CONFIGURE_VIEW;

	private var context:Context;
	private var domain:ApplicationDomain;
	private var settings:ViewSettings;
	private var viewRoots:Array = new Array();
	private var configuredViews:Dictionary = new Dictionary();

	private var cachedFastInjectEvents:Array = new Array();
	private var cachedAutowireEvents:Array = new Array();
	private var cachedConfigurationEvents:Array = new Array();
	
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
	 * @param settings the settings this ViewManager should use
	 */
	function DefaultViewManager (context:Context, domain:ApplicationDomain, settings:ViewSettings) {
		this.context = context;
		this.domain = domain;
		this.settings = settings;
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
	
	private function isAutoremove (target:Object, flag:Boolean) : Boolean {
		if (!(target is DisplayObject)) return false;
		var info:ClassInfo = ClassInfo.forInstance(target, domain);
		return (info.hasMetadata(Autoremove)) 
				? (info.getMetadata(Autoremove)[0] as Autoremove).value 
				: flag; 
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
		if (isAutoremove(viewRoot, settings.autoremoveViewRoots)) {
			stageEventFilter.addTarget(viewRoot, filteredViewRootRemoved, ignoredFilteredAddedToStage);
		}
		else {
			viewRoot.addEventListener(customRemovedEvent, viewRootRemoved);
		}
		viewRoot.addEventListener(explicitWireEvent, handleConfigurationEvent);
		viewRoot.addEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
		viewRoot.addEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
		viewRoot.addEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
		if (settings.autowireComponents) {
			viewRoot.addEventListener(settings.autowireFilter.eventType, prefilterView, true);
			viewRoot.addEventListener(settings.autowireFilter.eventType, prefilterView);
			viewRoot.addEventListener(ViewAutowireEvent.AUTOWIRE, handleAutowireEvent);
		}
	}
	
	private function handleRemovedViewRoot (viewRoot:DisplayObject) : void {
		if (isAutoremove(viewRoot, settings.autoremoveViewRoots)) {
			stageEventFilter.removeTarget(viewRoot);
		}
		else {
	 		viewRoot.removeEventListener(customRemovedEvent, viewRootRemoved);
		}
		viewRoot.removeEventListener(explicitWireEvent, handleConfigurationEvent);
		viewRoot.removeEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
		viewRoot.removeEventListener(ContextBuilderEvent.BUILD_CONTEXT, contextCreated);
		viewRoot.removeEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
		if (settings.autowireComponents) {
			viewRoot.removeEventListener(settings.autowireFilter.eventType, prefilterView, true);
			viewRoot.removeEventListener(settings.autowireFilter.eventType, prefilterView);
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
		if (settings.autowireFilter.prefilter(view)) {
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
		if (!context.configured) {
			if (cachedAutowireEvents.length == 0) {
				context.addEventListener(ContextEvent.CONFIGURED, handleCachedAutowireEvents);
			}
			cachedAutowireEvents.push(event);
			return;
		}
		processAutowireEvent(event);
	}
	
	private function processAutowireEvent (event:Event) : void {
		var view:DisplayObject = event.target as DisplayObject;
		if (configuredViews[view] != undefined) return;
		var mode:ViewAutowireMode = settings.autowireFilter.filter(view);
		if (mode == ViewAutowireMode.ALWAYS) {
			configureView(view, getDefinition(view, view.name));
		}
		else if (mode == ViewAutowireMode.CONFIGURED) {
			var definition:DynamicObjectDefinition = getDefinition(view, view.name);
			if (definition != null) {
				configureView(view, definition);
			}
		}
	}
	
	private function handleCachedAutowireEvents (event:ContextEvent) : void {
		for each (var autowireEvent:Event in cachedAutowireEvents) {
			processAutowireEvent(autowireEvent);
		}
		cachedAutowireEvents = new Array();
	}	

	protected function handleConfigurationEvent (event:Event) : void {
		event.stopImmediatePropagation();
		if (event is ViewConfigurationEvent) {
			ViewConfigurationEvent(event).markAsProcessed();
		}
		if (!context.configured) {
			if (cachedConfigurationEvents.length == 0) {
				context.addEventListener(ContextEvent.CONFIGURED, handleCachedConfigurationEvents);
			}
			cachedConfigurationEvents.push(event);
			return;
		}
		processConfigurationEvent(event);
	}
	
	private function processConfigurationEvent (event:Event) : void {
		var configTarget:Object = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configTarget : event.target;
		var configId:String = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configId 
				: (configTarget is DisplayObject) ? DisplayObject(configTarget).name : null;
		if (configuredViews[configTarget] != undefined) return;
		configureView(configTarget, getDefinition(configTarget, configId));
	}
	
	private function handleCachedConfigurationEvents (event:ContextEvent) : void {
		for each (var confEvent:Event in cachedConfigurationEvents) {
			processConfigurationEvent(confEvent);
		}
		cachedConfigurationEvents = new Array();
	}	
	
	protected function configureView (target:Object, definition:DynamicObjectDefinition) : void {
		log.debug("Add object '{0}' to {1}", target, context);
		if (target is IEventDispatcher) {
			if (isAutoremove(target, settings.autoremoveComponents)) {
				stageEventFilter.addTarget(target as DisplayObject, filteredComponentRemoved, ignoredFilteredAddedToStage);
			}
			else {
				IEventDispatcher(target).addEventListener(customRemovedEvent, componentRemoved);
			}
		}
		var dynObject:DynamicObject = context.addDynamicObject(target, definition);
		configuredViews[target] = dynObject;
	}
	
	protected function getDefinition (configTarget:Object, configId:String) : DynamicObjectDefinition {
		var definition:DynamicObjectDefinition;
		if (configId != null) {
			definition = getDefinitionById(configId, configTarget);
		}
		if (definition == null) {
			definition = getDefinitionByType(configTarget);
		}
		return definition;
	}
	
	private function getDefinitionById (id:String, configTarget:Object) : DynamicObjectDefinition {
		if (!context.containsObject(id)) return null;
		var definition:ObjectDefinition = context.getDefinition(id);
		if (definition is DynamicObjectDefinition && configTarget is definition.type.getClass()) {
			return definition as DynamicObjectDefinition;
		} else {
			return null;
		}
	}
	
	private function getDefinitionByType (configTarget:Object) : DynamicObjectDefinition {
		var type:Class = ClassInfo.forInstance(configTarget, domain).getClass();
		var count:int = context.getObjectCount(type);
		if (count == 0) {
			return null;
		}
		else if (count > 1) {
			throw new ContextError("More than one view definition for type " 
					+ getQualifiedClassName(configTarget) + " was registered");
		}
		else {
			var def:ObjectDefinition = context.getDefinitionByType(type);
			return (def is DynamicObjectDefinition) ? def as DynamicObjectDefinition : null;
		}
	}

	private function componentRemoved (event:Event) : void {
		var view:IEventDispatcher = IEventDispatcher(event.target);
		filteredComponentRemoved(view);
	}
	
	private function filteredComponentRemoved (view:IEventDispatcher) : void {
		log.debug("Remove object '{0}' from {1}", view, context);
		if (isAutoremove(view, settings.autoremoveComponents)) {
			stageEventFilter.removeTarget(view as DisplayObject);
		}
		else {
			view.removeEventListener(customRemovedEvent, componentRemoved);
		}
		var dynObject:DynamicObject = configuredViews[view];
		if (dynObject == null) return;
		delete configuredViews[view];
		dynObject.remove();
	}
	
	private function ignoredFilteredAddedToStage (view:IEventDispatcher) : void {
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
	
	
	
}
}
