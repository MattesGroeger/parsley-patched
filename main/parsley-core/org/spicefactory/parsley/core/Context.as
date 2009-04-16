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
 * Dispatched when the Context was fully initialized.
 * At this point all configuration was processed and all non-lazy singleton objects
 * in this Context have been instantiated and configured and their asynchronous
 * initializers (if any) have successfully completed.
 * 
 * <p>Some ContextBuilder implementations excute synchronously. In this case this
 * event will never fire. Thus before registering for this event you should check the
 * <code>initialized</code> property on the Context.</p>
 * 
 * @eventType org.spicefactory.parsley.core.events.ContextEvent.INITIALIZED
 */
[Event(name="initialized", type="org.spicefactory.parsley.core.events.ContextEvent")]

/**
 * Dispatched when Context initialization failed.
 * This may happen due to errors in processing the configuration or because some asynchronous
 * initializer on a non-lazy singleton failed. All objects that have already been created at
 * this point (partly or fully) will get their PreDestroy methods invoked.
 * 
 * <p>After the <code>INITIALIZED</code> event of this Context has fired and the
 * <code>initialized</code> property was set to true, this event can never fire.
 * In particular it does not fire if retrieving a lazy initializing object fails
 * after Context initialization.</p>
 * 
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * Dispatched when the Context was destroyed.
 * At this point all methods marked with [PreDestroy] on objects managed by this context 
 * have been invoked and any child Context instances were destroyed, too.
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
	
	
	//function initialize () : Boolean;
	
	function get initialized () : Boolean;
	
	function destroy () : void;
	
	function get destroyed () : Boolean;
	
	
	function get messageRouter () : MessageRouter;
	
	
}

}
