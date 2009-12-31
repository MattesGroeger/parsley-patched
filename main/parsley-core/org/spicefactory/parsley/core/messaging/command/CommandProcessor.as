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

/**
 * Processor to be passed to CommandTargets.
 * 
 * @author Jens Halm
 */
public interface CommandProcessor {
	
	/**
	 * The message that triggered Command execution.
	 */
	function get message () : Object;
	
	/**
	 * Processes the specified return value and returns a new Command instance.
	 * 
	 * @param returnValue the value returned by the method that executed the command
	 * @return a new Command instance
	 */
	function process (returnValue:*) : Command;
	
	
}
}
