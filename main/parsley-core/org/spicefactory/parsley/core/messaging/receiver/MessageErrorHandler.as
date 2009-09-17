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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.MessageProcessor;

/**
 * Handles errors thrown by regular message targets.
 * 
 * @author Jens Halm
 */
public interface MessageErrorHandler extends MessageReceiver {
	
	
	function get errorType () : ClassInfo;
	
	/**
	 * Handles an error thrown by a regular message target. 
	 * Processing further error handlers and targets will
	 * only happen if proceed is called on the specified processor.
	 * 
	 * @param processor the processor for the message
	 * @param error the error thrown by a message target
	 */
	function handleError (processor:MessageProcessor, error:Error) : void ;

	
}
}
