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
	
	
	private var _property:String;
	private var _objectType:Class;
	private var _objectId:String;
	
	
	/**
	 * Creates a new event instance.
	 * 
	 * @param objectType the property to inject into
	 * @param objectType the type of the object to inject
	 * @param objectId te type of the object to inject
	 */
	public function FastInjectEvent (property:String, objectType:Class, objectId:String = null) {
		super(FAST_INJECT, true);
		_property = property;
		_objectType = objectType;
		_objectId = objectId;
	}		
	
	/**
	 * The property to inject into.
	 */
	public function get property () : String {
		return _property; 
	}
	
	/**
	 * The type of the object to inject.
	 */
	public function get objectType () : Class {
		return _objectType;
	}
	
	/**
	 * The id of the object to inject.
	 */
	public function get objectId () : String {
		return _objectId;
	}
	
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		return new FastInjectEvent(property, objectType, objectId);
	}	
		
		
}
	
}