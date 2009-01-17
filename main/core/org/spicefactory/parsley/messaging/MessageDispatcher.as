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

package org.spicefactory.parsley.messaging {
import flash.events.IEventDispatcher;

/**
 * @author Jens Halm
 */
public interface MessageDispatcher {
	
	
	function registerMessageBinding (targetInstance:Object, targetProperty:String, 
			messageType:Class, messageProperty:String, selector:* = undefined) : void;
	
	function registerMessageHandler (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, messageProperties:Array = null, selector:* = undefined) : void;
			
	function registerMessageInterceptor (targetInstance:Object, targetMethod:String, 
			messageType:Class = null, selector:* = undefined) : void;
			
	function registerManagedEvents (dispatcher:IEventDispatcher, events:Array) : void;
	
	function dispatchMessage (message:Object) : void;
	
	function destroy () : void;
	
}
}
