/*
 * Copyright 2011 the original author or authors.
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
import org.spicefactory.parsley.core.context.Context;

/**
 * Represents a single message and all its relevant settings.
 * 
 * @author Jens Halm
 */
public interface Message {
	
	/**
	 * The actual message instance.
	 */
	function get instance () : Object;

	/**
	 * The type of the message.
	 */
	function get type () : ClassInfo;
	
	/**
	 * The selector to use to determine matching receivers.
	 */
	function get selector () : *;
	
	function set selector (value:*) : void;
	
	/**
	 * The Context the message was dispatched from.
	 */
 	function get senderContext () : Context;
 	
}
}
