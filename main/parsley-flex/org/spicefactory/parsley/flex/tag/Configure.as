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

package org.spicefactory.parsley.flex.tag {

/**
 * @author Jens Halm
 */
import mx.core.UIComponent;

import flash.events.Event;

public class Configure extends UIComponent {
	
	public var triggerEvent:String = "configureIOC";
		
	public override function initialize () : void {
		parent.addEventListener(Event.ADDED_TO_STAGE, dispatchConfigureEvent);
		if (parent.stage != null) {
			dispatchConfigureEvent();
		}
		super.initialize();
	}
	
	private function dispatchConfigureEvent (event:Event = null) : void  { 
		parent.dispatchEvent(new Event(triggerEvent, true));
	}
	
	override public function get includeInLayout () : Boolean {
		return false;
	}
	
}

}