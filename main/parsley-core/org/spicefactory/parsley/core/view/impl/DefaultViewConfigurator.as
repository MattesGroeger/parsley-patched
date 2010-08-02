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
import flash.utils.getQualifiedClassName;

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
	public function isAutoremove (target:Object, defaultMode:Boolean) : Boolean {
		if (!(target is DisplayObject)) return false;
		var info:ClassInfo = ClassInfo.forInstance(target, domain);
		return (info.hasMetadata(Autoremove)) 
				? (info.getMetadata(Autoremove)[0] as Autoremove).value 
				: defaultMode; 
	}
	
	/**
	 * @inheritDoc
	 */
	public function configure (target:Object, definition:DynamicObjectDefinition = null) : void {
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
	

}
}