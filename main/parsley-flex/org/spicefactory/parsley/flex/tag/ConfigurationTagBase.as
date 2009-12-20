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
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.errors.IllegalArgumentError;

import mx.core.IMXMLObject;
import mx.core.UIComponent;
import mx.events.FlexEvent;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Base class for MXML configuration tags that require both, the associated document component being added to the stage
 * and the bindings for the tag being executed, before performing its work. Subclasses only have to overwrite the
 * template method <code>executeAction</code> for doing the actual work.
 * 
 * @author Jens Halm
 */
public class ConfigurationTagBase implements IMXMLObject {
	
	
	/**
	 * Invoked when the specified view has been added to the stage
	 * and is fully initialized (in case it is a Flex component).
	 * The default implementation throws an Error, subclasses are expected
	 * to override this method. The view is the document instance
	 * associated with this tag class.
	 * 
	 * @param view the fully initialized view
	 */
	protected function executeAction (view:DisplayObject) : void {
		throw new AbstractMethodError(); 
	}
	
	
	/**
	 * @private
	 */
	public function initialized (document:Object, id:String) : void {
		if (!(document is DisplayObject)) {
			throw new IllegalArgumentError("The tag is supposed to be used within MXML components that extend DisplayObject");
		}
		var view:DisplayObject = DisplayObject(document);
		
		if (isOnStage(view) && isInitialized(view)) {
			executeAction(view);
		}
		else if (!isOnStage(view)) {
			view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		else {
			view.addEventListener(FlexEvent.INITIALIZE, viewInitialized);
		}
	}
	
	private function addedToStage (event:Event) : void  {
		var view:DisplayObject = DisplayObject(event.target);
		view.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		if (isInitialized(view)) {
			executeAction(view);
		}
		else {
			view.addEventListener(FlexEvent.INITIALIZE, viewInitialized);
		}
	}
	
	private function viewInitialized (event:Event) : void  {
		var view:DisplayObject = DisplayObject(event.target);
		view.removeEventListener(FlexEvent.INITIALIZE, viewInitialized);
		if (isOnStage(view)) {
			executeAction(view);
		}
		else {
			view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
	}
	
	private function isInitialized (view:DisplayObject) : Boolean {
		return (view is UIComponent) ? UIComponent(view).initialized : true;
	}
	
	private function isOnStage (view:DisplayObject) : Boolean {
		return (view.stage != null);
	}
	
	
}
}
