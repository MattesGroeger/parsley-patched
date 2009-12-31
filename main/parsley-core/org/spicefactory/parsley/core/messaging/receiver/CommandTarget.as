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

package org.spicefactory.parsley.core.messaging.receiver {
import org.spicefactory.parsley.core.messaging.command.CommandProcessor;

/**
 * Represents a message receiver that initiates the execution of an asynchronous command.
 * 
 * @author Jens Halm
 */
public interface CommandTarget extends MessageReceiver {
	
	/**
	 * The type of the values this command will return.
	 */
	function get returnType () : Class;
	
	/**
	 * Executes the command. Implementations have to invoke <code>processor.process</code>,
	 * passing the value returned by the command method to the processor. Otherwise no
	 * Command instance will be created for this invocation and thus no CommandObservers
	 * will be invoked. The <code>process</code> method returns the Command instance
	 * created based on the specified return value and can be used to register 
	 * a status handler for cleaning up after command execution. A status handler
	 * added by this method will always execute before CommandObserver targets will
	 * be invoked.
	 * 
	 * @param processor the processor for this command
	 */
	function executeCommand (processor:CommandProcessor) : void;
	
	
}
}
