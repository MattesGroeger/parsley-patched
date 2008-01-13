/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.mvc {

import flash.utils.getQualifiedClassName;

/**
 * The base class for all events processed by the <code>FrontController</code>.
 * Does not extend <code>flash.events.Event</code> since its API was not suitable
 * for the requirements of event processing in the Parsley MVC Framework.
 * This differs from other parts of the framework which in general builds upon
 * the Flash Player Event Model.
 * 
 * <p>This class is not abstract. It can be used as is or you can create subclasses
 * to include further properties or methods.</p>
 * 
 * @author Jens Halm
 */
public class ApplicationEvent {
	
	
	private var _name:String;
	private var _controller:FrontController;
	
	
	/**
	 * Creates a new instance.
	 */
	function ApplicationEvent (name:String) {
		_name = name;
	}
	
	
	/**
	 * @private
	 */
	internal function setFrontController (controller:FrontController) : void {
		_controller = controller;
	}
	
	/**
	 * The name of the event.
	 */
	public function get name () : String {
		return _name;
	}
	
	/**
	 * The <code>>FrontController</code> that dispatched this event.
	 */
	public function get controller () : FrontController {
		return _controller;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return getQualifiedClassName(this) + "." + name;
	}
	
	
}
}
