/*
 * Copyright 2010 the original author or authors.
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
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.metadata.Autoremove;
import org.spicefactory.parsley.core.view.util.StageEventFilter;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the ViewConfigurator interface.
 * 
 * @author Jens Halm
 */
public class DefaultViewConfigurator implements ViewConfigurator {
	
	
	private static const log:Logger = LogContext.getLogger(DefaultViewConfigurator);
	
	private var customRemovedEvent:String = "removeView";
	private var stageEventFilter:StageEventFilter = new StageEventFilter();
	
	private var configuredViews:Dictionary = new Dictionary();
	
	private var _domain:ApplicationDomain;
	private var context:Context;
	private var settings:ViewSettings;
	
	
	function DefaultViewConfigurator (context:Context, domain:ApplicationDomain, settings:ViewSettings) {
		this.context = context;
		this._domain = domain;
		this.settings = settings; 
	}

	
	/**
	 * @inheritDoc
	 */
	public function isConfigured (target:Object) : Boolean {
		return (configuredViews[target] != undefined);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isAutoremove (target:Object, defaultMode:Boolean, useMetadata:Boolean = true) : Boolean {
		if (!(target is DisplayObject)) return false;
		if (!useMetadata) return defaultMode;
		var info:ClassInfo = ClassInfo.forInstance(target, domain);
		return (info.hasMetadata(Autoremove)) 
				? (info.getMetadata(Autoremove)[0] as Autoremove).value 
				: defaultMode; 
	}
	
	/**
	 * @inheritDoc
	 */
	public function configure (target:Object, definition:DynamicObjectDefinition = null) : void {
		log.debug("Add view '{0}' to {1}", target, context);
		var autoremove:Boolean = false;
		if (target is IEventDispatcher) {
			autoremove = isAutoremove(target, settings.autoremoveComponents);
			if (autoremove) {
				stageEventFilter.addTarget(target as DisplayObject, filteredComponentRemoved, ignoredFilteredAddedToStage);
			}
			else {
				IEventDispatcher(target).addEventListener(customRemovedEvent, componentRemoved);
			}
		}
		var dynObject:DynamicObject = context.addDynamicObject(target, definition);
		configuredViews[target] = new ManagedView(dynObject, autoremove);
	}

	/**
	 * @inheritDoc
	 */
	public function getDefinition (configTarget:Object, configId:String) : DynamicObjectDefinition {
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
		
		var ids:Array = context.getObjectIds(type);
		var def:DynamicObjectDefinition = null;
		
		for each (var id:String in ids) {
			var candidate:ObjectDefinition = context.getDefinition(id);
			if (candidate is DynamicObjectDefinition && configTarget is candidate.type.getClass()) {
				if (def == null) {
					def = candidate as DynamicObjectDefinition; 
				}
				else {
					throw new ContextError("More than one view definition for type " 
							+ type + " was registered");
				}
			}
		}
		return def;
	}

	private function componentRemoved (event:Event) : void {
		var view:IEventDispatcher = IEventDispatcher(event.target);
		filteredComponentRemoved(view);
	}
	
	private function filteredComponentRemoved (view:IEventDispatcher) : void {
		log.debug("Remove view '{0}' from {1}", view, context);
		var managedView:ManagedView = configuredViews[view];
		if (managedView == null) return;
		if (managedView.autoremove) {
			stageEventFilter.removeTarget(view as DisplayObject);
		}
		else {
			view.removeEventListener(customRemovedEvent, componentRemoved);
		}
		
		delete configuredViews[view];
		managedView.dynamicObject.remove();
	}
	
	private function ignoredFilteredAddedToStage (view:IEventDispatcher) : void {
		/* do nothing */
	}
}
}

import org.spicefactory.parsley.core.context.DynamicObject;

class ManagedView {
	
	public var dynamicObject:DynamicObject;
	public var autoremove:Boolean;
	
	function ManagedView (dynamicObject:DynamicObject, autoremove:Boolean) {
		this.dynamicObject = dynamicObject;
		this.autoremove = autoremove;
	}
}
