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

package org.spicefactory.parsley.flex.tag.view {
import org.spicefactory.parsley.core.view.util.StageEventFilterCollection;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.events.FastInjectEvent;
import org.spicefactory.parsley.core.view.util.StageEventFilter;
import org.spicefactory.parsley.core.view.impl.ViewInjection;
import org.spicefactory.parsley.flex.tag.ConfigurationTagBase;

import mx.core.UIComponent;
import mx.events.FlexEvent;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Dispatched immediately after injections have been performed.
 */
[Event(name="injectionComplete", type="flash.events.Event")]

/**
 * Dispatched after injections have been performed and the creationComplete event of the document
 * this tag is placed upon has been fired.
 */
[Event(name="creationComplete", type="flash.events.Event")]

/**
 * Dispatched for the first time after injections have been performed and the creationComplete event of the document
 * this tag is placed upon has been fired.
 * Subsequent dispatching will ignore stage events caused by reparenting. 
 */
[Event(name="addedToStage", type="flash.events.Event")]

/**
 * Dispatched when the component is removed from the stage, but ignores interim events caused by reparenting.
 */
[Event(name="removedFromStage", type="flash.events.Event")]


[DefaultProperty("injections")]

/**
 * MXML Tag that can be used for views that wish to retrieve a particular object from the IOC Container
 * without actually getting wired to it to avoid the cost of reflection.
 * The tag allows the object to be selected by type or by id.
 * 
 * @author Jens Halm
 */
public class FastInjectTag extends ConfigurationTagBase {
	
	
	private static const log:Logger = LogContext.getLogger(FastInjectTag);
	
	private static const INJECTION_COMPLETE:String = "injectionComplete";

	
	private var stageEventFilter:StageEventFilterCollection = new StageEventFilterCollection();
	
	
	/**
	 * @private
	 */
	function FastInjectTag () {
		/*
		 * Using a lower priority here to make sure to execute after ContextBuilders listening for the 
		 * same event types of the document instance.
		 */
		super(-1);
	}
	
	
	/**
	 * The property to inject into.
	 */
	public var property:String;
	
	/**
	 * The type of the object to inject.
	 */
	public var type:Class;
	
	/**
	 * The id of the object to inject.
	 */
	public var objectId:String;
	
	[ArrayElementType("org.spicefactory.parsley.flex.tag.view.InjectTag")]
	/**
	 * List of injections to perform.
	 */
	public var injections:Array = [];
	
	
	private var view:DisplayObject;
	
	
	/**
	 * @private
	 */
	protected override function executeAction (view:DisplayObject) : void { 
		this.view = view;
		var viewInjections:Array = new Array();
		if (property != null) {
			viewInjections.push(new ViewInjection(property, type, objectId));
		}
		for each (var injectTag:InjectTag in injections) {
			viewInjections.push(new ViewInjection(injectTag.property, injectTag.type, injectTag.objectId));
		}
		var event:FastInjectEvent = new FastInjectEvent(viewInjections, completeHandler);
		view.dispatchEvent(event);
		if (!event.received) {
			log.warn("FastInject tag could not be processed for target " + view + " and property " + property
					+ ": no Context found in view hierarchy");
		}
	}

	private function completeHandler () : void {
		processEvents(view);
	}
		
	private function processEvents (view:DisplayObject) : void {
		dispatchEvent(new Event(INJECTION_COMPLETE));
		if (view.stage != null) {
			dispatchEvent(new Event(Event.ADDED_TO_STAGE));
		}
		if (view is UIComponent) {
			var comp:UIComponent = UIComponent(view);
			if (comp.initialized) {
				dispatchEvent(new Event(FlexEvent.CREATION_COMPLETE));
			}
			else {
				comp.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			}
		}
		if (hasEventListener(Event.ADDED_TO_STAGE) || hasEventListener(Event.REMOVED_FROM_STAGE)) {
			stageEventFilter.addTarget(view, filteredComponentRemoved, filteredComponentAdded);
		}
	}
	
	private function creationCompleteHandler (event:Event) : void {
		UIComponent(event.target).removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		dispatchEvent(new Event(FlexEvent.CREATION_COMPLETE));
	}
	
	private function filteredComponentRemoved (view:DisplayObject) : void {
		dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
	}

	private function filteredComponentAdded (view:DisplayObject) : void {
		dispatchEvent(new Event(Event.ADDED_TO_STAGE));
	}
	
	
}
}
