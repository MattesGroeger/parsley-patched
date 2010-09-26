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

package org.spicefactory.parsley.core.view.util {
import flash.display.DisplayObject;
import flash.utils.Dictionary;

/**
 * Utility class for filtering stage events that were only caused by reparenting a DisplayObject.
 * 
 * @author Jens Halm
 */
public class StageEventFilter {
	
	
	private var handlers:Dictionary = new Dictionary();
	
	
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
	public function addTarget (view:DisplayObject, removedHandler:Function, addedHandler:Function = null) : void {
		handlers[view] = new ViewHandler(view, removedHandler, addedHandler);
	}
	
	/**
	 * Removes a target so that stage event handlers are no longer invoked.
	 * 
	 * @param view the view to stop filtering stage events for
	 */
	public function removeTarget (view:DisplayObject) : void {
		var handler:ViewHandler = handlers[view];
		if (handler) {
			handler.dispose();
			delete handlers[view];
		}
	}
	
	
}
}

import flash.display.DisplayObject;
import flash.events.Event;

class ViewHandler {
	
	
	private var view:DisplayObject;
	private var removedHandler:Function;
	private var addedHandler:Function;
	
	private var removedInCurrentFrame:Boolean;
	
	
	function ViewHandler (view:DisplayObject, removedHandler:Function, addedHandler:Function) {
		this.view = view;
		this.removedHandler = removedHandler;
		this.addedHandler = addedHandler;
		view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		view.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
	}
	
	
	public function dispose () : void {
		view.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		view.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		view.removeEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function addedToStage (event:Event) : void {
		if (removedInCurrentFrame) {
			resetFrame();
		}
		else if (addedHandler != null) {
			addedHandler(view);
		}
	}
	
	private function removedFromStage (event:Event) : void {
		removedInCurrentFrame = true;
		view.addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function enterFrame (event:Event) : void {
		resetFrame();
		removedHandler(view);
	}
	
	private function resetFrame () : void {
		removedInCurrentFrame = false;
		view.removeEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	
}


