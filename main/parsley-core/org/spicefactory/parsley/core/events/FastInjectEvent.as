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
 
package org.spicefactory.parsley.core.events {
import flash.events.Event;

/**
 * Event that fires when a view component wishes to retrieve a single object from the IOC container.
 * 
 * @author Jens Halm
 */
public class FastInjectEvent extends Event {


	/**
	 * Constant for the type of bubbling event fired when a view component wishes to 
	 * retrieve a single object from the IOC container that is associated with the 
	 * nearest parent in the view hierarchy.
	 * 
	 * @eventType configureView
	 */
	public static const FAST_INJECT : String = "fastInject";
	
	
	private var _injections:Array;
	
	private var _processed:Boolean;
	
	
	/**
	 * Creates a new event instance.
	 * 
	 * @param injections list of injections to perform
	 */
	public function FastInjectEvent (injections:Array) {
		super(FAST_INJECT, true);
		_injections = injections;
	}		
	
	/**
	 * List of injections to perform.
	 */
	public function get injections () :Array {
		return _injections; 
	}
	
	/**
	 * Indicates whether this event instance has already been processed by a Context.
	 */
	public function get processed () : Boolean {
		return _processed;
	}
	
	/**
	 * Marks this event instance as processed by a corresponding Context.
	 */
	public function markAsProcessed () : void {
		_processed = true;
	}
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		return new FastInjectEvent(injections);
	}	
		
		
}
	
}