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
import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * Responsible for listening to events of an Flash <code>IEventDispatcher</code>, transforming these
 * events to Parsley ApplicationEvents and dispatching them through a <code>FrontController</code>. 
 * 
 * <p>Note that in many projects there may not be the need to use this class. If you create new
 * classes that depend on the Parsley MVC API anyway, they can create and dispatch ApplicationEvents
 * directly. This class is merely intended as a convenient way to adapt existing classes.</p>
 * 
 * @author Jens Halm
 */
public class EventSource {
	
	
	private var _dispatcher:IEventDispatcher;
	private var _transformer : Function;
	private var _eventTypes : Array;
	private var _controller : FrontController;
	
	
	/**
	 * Creates a new instance. 
	 * 
	 * <p>The specfied transformer function must have the
	 * following signature:</p>
	 * 
	 * <code>
	 * function transform (event:Event) : ApplicationEvent
	 * </code>
	 * <br/>
	 * @param dispatcher the event dispatcher to register event listeners for
	 * @param transformer the function that transforms Flash events to Parsley ApplicationEvents
	 * @param eventTypes Array of event types that should be transformed
	 */
	function EventSource (dispatcher:IEventDispatcher, 
			transformer:Function, eventTypes:Array) {
		_dispatcher = dispatcher;
		_transformer = transformer;
		_eventTypes = eventTypes;
	}
	
	/**
	 * @private
	 */
	internal function activate (controller:FrontController) : void {
		_controller = controller;
		for each (var eventType:String in _eventTypes) {
			_dispatcher.addEventListener(eventType, handleEvent);
		}	
	}
	
	/**
	 * @private
	 */
	internal function deactivate () : void {
		for each (var eventType:String in _eventTypes) {
			_dispatcher.removeEventListener(eventType, handleEvent);
		}	
	}
	
	private function handleEvent (event:Event) : void {
		_controller.dispatchEvent(_transformer(event));
	}
	
	
}

}
