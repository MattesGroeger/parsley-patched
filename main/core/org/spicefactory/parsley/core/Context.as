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
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.messaging.MessageRouter;

/**
 * @author Jens Halm
 */
public interface Context {
	
	
	function get objectCount () : uint;
	
	function get objectIds () : Array;
	
	function containsObject (id:String) : Boolean;
	
	function getObjectsByType (type:Class) : Array;
	
	function getType (id:String) : Class;
	
	function getObject (id:String) : Object;
	
	function getFactory (id:String) : Object;
	
	function addDestroyCommand (com:Command) : void;
	
	function destroy () : void;
	
	function get messageDispatcher () : MessageRouter;
	
	
}

}
