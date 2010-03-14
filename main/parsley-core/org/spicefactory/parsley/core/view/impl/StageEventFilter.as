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
import flash.events.IEventDispatcher;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

/**
 * Utility class for filtering stage events that were only caused by reparenting a DisplayObject.
 * 
 * @author Jens Halm
 */
public class StageEventFilter {
	
	
	
	private static var timer:Timer;
	
	private var removedViews:Dictionary = new Dictionary();

	private var removedHandlers:Dictionary = new Dictionary();
	private var addedHandlers:Dictionary = new Dictionary();
	
	private var hasTimerListener:Boolean;
	
	
	
	private function checkTimer () : void {
		if (timer == null) {
			timer = new Timer(1, 1);
			timer.addEventListener(TimerEvent.TIMER, clearTimer, false, 1);
			timer.start();
		}
		if (!hasTimerListener) {
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			hasTimerListener = true;
		}
	}
	
	private static function clearTimer (event:Event) : void {
		timer.removeEventListener(TimerEvent.TIMER, clearTimer);
		timer = null;
	}
	
	
	private function handleTimer (event:Event) : void {
		IEventDispatcher(event.target).removeEventListener(TimerEvent.TIMER, handleTimer);
		hasTimerListener = false;
		var handlerMap:Dictionary = removedViews;
		removedViews = new Dictionary();
		for (var key:Object in handlerMap) {
			removedHandlers[key](key);
		}
	}
	
	/**
	 * Adds a target to filter the stage events for. The specified handlers will only be invoked
	 * when an addedToStage or removedFromStage event occurs that is not just temporarily as those
	 * that fire when a DisplayObject gets reparented as the result of some LayoutManager operation (e.g.
	 * adding scrollbars).
	 * 
	 * <p>The parameter passed to the handlers is the DisplayObject, not the event.</p>
	 * 
	 * @param view the view to filter all stage events for
	 * @param removedHandler the handler to invoke for all real removedFromStage events
	 * @param addedHandler the handler to invoke for all real addedToStage events
	 */
	public function addTarget (view:DisplayObject, removedHandler:Function, addedHandler:Function) : void {
		view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		view.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		removedHandlers[view] = removedHandler;
		addedHandlers[view] = addedHandler;
	}
	
	/**
	 * Removes a target so that stage event handlers are no longer invoked.
	 * 
	 * @param view the view to stop filtering stage events for
	 */
	public function removeTarget (view:DisplayObject) : void {
		view.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		view.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		delete removedHandlers[view];
		delete addedHandlers[view];
		delete removedViews[view];
	}
	
	private function addedToStage (event:Event) : void {
		if (removedViews[event.target] != undefined) {
			delete removedViews[event.target];
		}
		else {
			addedHandlers[event.target](event.target);
		}
	}
	
	private function removedFromStage (event:Event) : void {
		removedViews[event.target] = true;
		checkTimer();
	}
	
	
}
}
