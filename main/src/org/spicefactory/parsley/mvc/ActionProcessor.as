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

/**
 * An <code>ActionProcessor</code> is responsible for handling a single event processing.
 * That involves invoking all interceptors and then all actions registered for that event.
 * 
 * @author Jens Halm
 */
public class ActionProcessor {
	
	
	private var _event:ApplicationEvent;
	private var actions:Array;
	private var interceptors:Array;
	
	/**
	 * @private
	 */
	function ActionProcessor (event:ApplicationEvent, actions:Array, interceptors:Array) {
		_event = event;
		this.actions = actions;
		this.interceptors = interceptors;
	}
	
	
	/**
	 * The event that this processor handles.
	 */
	public function get event () : ApplicationEvent {
		return _event;
	}
	
	
	/**
	 * Resumes with event processing. No further interceptors or actions
	 * will be invoked unless this method is invoked.
	 */
	public function proceed () : void {
		if (interceptors.length > 0) {
			var ic:ActionInterceptor = interceptors.shift() as ActionInterceptor;
			ic.intercept(this);
		} else {
			for each (var action:Action in actions) {
				action.execute(event);
			}
		}
	}	

	
}

}