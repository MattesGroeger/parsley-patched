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

import flash.utils.getQualifiedClassName;

/**
 * Abstract base class for the Root and Module ViewManagers.
 * 
 * @author Jens Halm
 */
public class AbstractViewManager {
	
	
	private static const log:Logger = LogContext.getLogger(AbstractViewManager);
	

	private var _triggerEvent:String = "configureIOC";
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param triggerEvent the event type components will use to signal that they wish to get wired
	 */
	function AbstractViewManager (triggerEvent:String = null) {
		if (triggerEvent != null) {
			_triggerEvent = triggerEvent;
		}
	}
	
	/**
	 * The event type components will use to signal that they wish to get wired.
	 */
	public function get triggerEvent () : String {
		return _triggerEvent;
	}
	
	/**
	 * Returns the Context the specified component should be wired to.
	 * 
	 * @param component the component to be wired
	 * @return the Context to wire the component to
	 */
	protected function getContext (component:DisplayObject) : FlexViewContext {
		throw new AbstractMethodError();
	}
	
	/**
	 * Adds a listener for the trigger event type to the specified component.
	 * 
	 * @param component the component to add the listener to
	 */
	protected function addListener (component:DisplayObject) : void {
		log.info("Add listener for {0}/{1} and triggerEvent {2}", component.name, getQualifiedClassName(component), _triggerEvent);
		component.addEventListener(_triggerEvent, handleConfigureEvent);
	}
	
	/**
	 * Removes the listener for the trigger event type from the specified component.
	 * 
	 * @param component the component to remove the listener from
	 */
	protected function removeListener (component:DisplayObject) : void {
		component.removeEventListener(_triggerEvent, handleConfigureEvent);
	}
	
	private function handleConfigureEvent (event:Event) : void {
		event.stopImmediatePropagation();
		var component:DisplayObject = DisplayObject(event.target);
		log.debug("Add component '{0}' to ViewContext", component);
		addComponent(component);
	}
	
	/**
	 * Adds the specified component to the Parsley Context.
	 * 
	 * @param component the component to add to the Parsley Context
	 */
	protected function addComponent (component:DisplayObject) : void {
		var context:FlexViewContext = getContext(component);
		if (context == null) {
			log.warn("No Context found for triggerEvent {0} and component {1}", triggerEvent, component);
			return;
		}
		context.addComponent(component);
	}


}
}

