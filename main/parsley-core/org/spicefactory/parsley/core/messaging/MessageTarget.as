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

package org.spicefactory.parsley.core.messaging {
import org.spicefactory.lib.reflect.ClassInfo;

/**
 * Represent a registered target for a message.
 * 
 * @author Jens Halm
 */
public interface MessageTarget {
	
	
	/**
	 * The type of the target object receiving the messages.
	 */
	function get targetType () : ClassInfo ;
	
	/**
	 * The instance receiving the messages.
	 */
	function get targetInstance () : Object ;
	
	/**
	 * The message type that the target registered for.
	 */
	function get messageType () : ClassInfo ;
	
	/**
	 * An optional selector value to be used for selecting matching message targets.
	 */
	function get selector () : * ;
	
	/**
	 * Indicates whether this target is an interceptor or a regular target.
	 * Interceptors will always be executed before regular targets.
	 */
	function get interceptor () : Boolean ;
	
	/**
	 * Handles a message for this target.
	 * 
	 * @param processor the processor for the message
	 */
	function handleMessage (processor:MessageProcessor) : void ;

	/**
	 * Unregisters this target so that it no longer receives messages.
	 */
	function unregister () : void ;
	
	
}
}
