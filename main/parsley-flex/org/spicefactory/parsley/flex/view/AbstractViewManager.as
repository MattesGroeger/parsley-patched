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
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * @author Jens Halm
 */
public class AbstractViewManager {
	
	
	private static const log:Logger = LogContext.getLogger(AbstractViewManager);
	

	private var _triggerEvent:String = "configureIOC";
	
	
	function AbstractViewManager (triggerEvent:String = null) {
		if (triggerEvent != null) {
			_triggerEvent = triggerEvent;
		}
	}
	
	
	public function get triggerEvent () : String {
		return _triggerEvent;
	}
	
	protected function getContext (component:DisplayObject) : FlexViewContext {
		throw new AbstractMethodError();
	}
	
	protected function addListener (component:DisplayObject) : void {
		component.addEventListener(_triggerEvent, addComponent);
	}
	
	protected function removeListener (component:DisplayObject) : void {
		component.removeEventListener(_triggerEvent, addComponent);
	}
	
	private function addComponent (event:Event) : void {
		event.stopImmediatePropagation();
		var component:DisplayObject = DisplayObject(event.target);
		var context:FlexViewContext = getContext(component);
		if (context == null) {
			log.warn("No Context found for triggerEvent {0} and component {1}", triggerEvent, component);
			return;
		}
		context.addComponent(component);
	}


}
}

