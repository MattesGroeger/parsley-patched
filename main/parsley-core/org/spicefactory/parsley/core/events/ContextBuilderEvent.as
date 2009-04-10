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
 
package org.spicefactory.parsley.core.events {
import flash.events.Event;

/**
 * Event that fires when a ContextBuilder changes its internal state.
 * 
 * @author Jens Halm
 */
public class ContextBuilderEvent extends Event {

	
	/**
	 * Constant for the type of event fired when a ContextBuilder instance completed.
	 * 
	 * @eventType complete
	 */
	public static const COMPLETE : String = "complete";
	
	
	/**
	 * Creates a new event instance.
	 * 
	 * @param type the type of this event
	 */
	public function ContextBuilderEvent (type:String) {
		super(type);
	}		
		
}
	
}