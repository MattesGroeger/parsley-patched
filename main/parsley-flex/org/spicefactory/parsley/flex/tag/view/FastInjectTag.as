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
import org.spicefactory.parsley.core.events.FastInjectEvent;
import org.spicefactory.parsley.flex.tag.ConfigurationTagBase;

import flash.display.DisplayObject;

/**
 * MXML Tag that can be used for views that wish to retrieve a particular object from the IOC Container
 * without actually getting wired to it to avoid the cost of reflection.
 * The tag allows the object to be selected by type or by id.
 * 
 * @author Jens Halm
 */
public class FastInjectTag extends ConfigurationTagBase {
	
	
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
	
	
	/**
	 * @private
	 */
	protected override function executeAction (view:DisplayObject) : void { 
		view.dispatchEvent(new FastInjectEvent(property, type, objectId));
	}
	
	
}
}
