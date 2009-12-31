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

package org.spicefactory.parsley.core.messaging.command {
import org.spicefactory.lib.reflect.ClassInfo;

/**
 * Represents a single Command execution.
 * 
 * @author Jens Halm
 */
public interface Command {
	
	
	/**
	 * The message that triggered the Command.
	 */
	function get message () : Object;
	
	/**
	 * The selector used for matching the Command method.
	 */
	function get selector () : *;
	
	/**
	 * The return value from the Command execution.
	 */
	function get returnValue () : *;
	
	/**
	 * The current status of the command.
	 */
	function get status () : CommandStatus;
	
	/**
	 * Returns the result for the specified target type.
	 * 
	 * <p>The type is only passed to the method to allow to select
	 * amongst multiple values (like choosing between <code>ResultEvent.result</code>
	 * and the event instance itself). Implementations should not throw an Error if
	 * the type does not match, as there might be a Converter registered for the target type.</p>
	 * 
	 * <p>This method should throw an error if the current status 
	 * is <code>EXECUTE</code> or <code>CANCEL</code>.</p>
	 * 
	 * @param targetType The expected type on the target (parameter or property)
	 * @return the best match for the specified target type
	 */
	function getResult (targetType:ClassInfo) : *;
	
	/**
	 * Adds a handler function to invoke when the Command changes its status. 
	 * This may either be a successful completion, or due to cancellation or an error. 
	 * 
	 * @param handler the handler to invoke upon command completion
	 * @param params any additional parameters that should be passed to the handler in addition to the Command itself
	 */
	function addStatusHandler (handler:Function, ...params) : void;
	
	
}
}
