/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.core {
import org.spicefactory.parsley.messaging.MessageRouter;

import flash.events.IEventDispatcher;

/**
 * Dispatched when the Context was destroyed.
 * 
 * @eventType org.spicefactory.parsley.core.events.ContextEvent.DESTROYED
 */
[Event(name="destroyed", type="org.spicefactory.parsley.core.events.ContextEvent")]

/**
 * @author Jens Halm
 */
public interface Context extends IEventDispatcher {
	
	
	function getObjectCount (type:Class = null) : uint;
	
	function getObjectIds (type:Class = null) : Array;
	
	
	function containsObject (id:String) : Boolean;
	
	function getType (id:String) : Class;
	
	function getObject (id:String) : Object;
	

	function getObjectByType (type:Class, required:Boolean = false) : Object;

	function getAllObjectsByType (type:Class) : Array;
	
	
	function initialize () : Boolean;
	
	function get initialized () : Boolean;
	
	function destroy () : void;
	
	function get destroyed () : Boolean;
	
	
	function get messageRouter () : MessageRouter;
	
	
}

}
