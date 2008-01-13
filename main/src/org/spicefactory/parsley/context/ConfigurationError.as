/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;	

/**
 * Error thrown for configuration errors.
 * 
 * @author Jens Halm
 */
public class ConfigurationError extends Error {
	
	// TODO - 1.1.0 - refactor as subclass of NestedError after Spicelib 1.1 release
		
	private var _message:String;
	private var _cause:Error;
	
	private static var _logger:Logger;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param message the error message
	 * @param cause the original cause of the error
	 */	
	public function ConfigurationError (msg:String, cause:Error = null) {
		super((cause == null) ? msg : msg + " [cause: " + cause + "]");
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.context.ConfigurationError");
		}
		_message = message;
		_cause = cause;
		_logger.error(_message);
	}
	
		
		
}

}