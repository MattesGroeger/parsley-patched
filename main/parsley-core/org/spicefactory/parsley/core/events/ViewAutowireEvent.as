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
 * Event that gets dispatched through view objects to check whether they are applicable 
 * for autowiring them to the IOC container.
 * 
 * @author Jens Halm
 */
public class ViewAutowireEvent extends Event {


	/**
	 * Constant for the type of bubbling event gets dispatched through view objects to check whether they are applicable 
 	 * for autowiring them to the IOC container.
	 * 
	 * @eventType configureView
	 */
	public static const AUTOWIRE : String = "autowire";
	
	
	/**
	 * Creates a new event instance.
	 */
	public function ViewAutowireEvent () {
		super(AUTOWIRE, true);
	}		
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		return new ViewAutowireEvent();
	}	
		
		
}
	
}