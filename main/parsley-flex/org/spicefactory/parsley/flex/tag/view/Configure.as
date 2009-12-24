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

package org.spicefactory.parsley.flex.tag.view {
	import org.spicefactory.parsley.flex.tag.ConfigurationTagBase;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;


import flash.display.DisplayObject;
import flash.events.Event;

/**
 * MXML Tag that can be used for views that wish to be wired to the IOC Container.
 * With the target property of this tag the object to be wired to the Context can be explicitly specified
 * and does not have to be a DisplayObject. If the target property is not used the document object this tag is placed
 * upon will be wired. That object must always be a DisplayObject since it is used to 
 * dispatch a bubbling event.
 * 
 * @author Jens Halm
 */
public class Configure extends ConfigurationTagBase {
	
	
	/**
	 * @private
	 */
	function Configure () {
		/*
		 * Using a lower priority here to make sure to execute after ContextBuilders listening for the 
		 * same event types of the document instance.
		 */
		super(-1);
	}
	
	
	/**
	 * The target object to be wired to the Context.
	 * If this property is not set explicitly then the document object this tag
	 * was placed upon will be wired.
	 */
	public var target:Object;
	
	/**
	 * Indicates whether the wiring should happen repeatedly whenever the 
	 * object is added to the stage. When set to false it is only wired once.
	 * The default is true.
	 */
	public var repeat:Boolean = true;
	
	
	protected override function executeAction (view:DisplayObject) : void { 
		view.dispatchEvent(new ViewConfigurationEvent(target));
		if (repeat) {
			view.addEventListener(Event.ADDED_TO_STAGE, repeatAction);
		}
	}
	
	private function repeatAction (event:Event) : void {
		DisplayObject(event.target).dispatchEvent(new ViewConfigurationEvent(target));
	}
	
	
}
}