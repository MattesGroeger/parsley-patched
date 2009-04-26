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

package org.spicefactory.lib.logging.flex {
import org.spicefactory.lib.logging.LogFactory;
import org.spicefactory.lib.logging.LogUtil;
import org.spicefactory.lib.logging.Logger;

import mx.logging.ILogger;
import mx.logging.Log;

/**
 * @author Jens Halm
 */
public class FlexLogFactory implements LogFactory {

	public function getLogger (name:Object) : Logger {
		var flexLogger:ILogger = Log.getLogger(LogUtil.getLogName(name));
		return new FlexDelegateLogger(flexLogger);
	}
	
}
}

import org.spicefactory.lib.logging.Logger;

import mx.logging.ILogger;
import mx.logging.Log;

class FlexDelegateLogger implements Logger {


	private var delegate:ILogger;


	function FlexDelegateLogger (delegate:ILogger) {
		this.delegate = delegate;
	}

	
	public function get name () : String {
		return delegate.category;
	}


	public function isTraceEnabled () : Boolean {
		return Log.isDebug(); // Flex logging has no TRACE level
	}

	public function isDebugEnabled () : Boolean {
		return Log.isDebug();
	}

	public function isInfoEnabled () : Boolean {
		return Log.isInfo();
	}

	public function isWarnEnabled () : Boolean {
		return Log.isWarn();
	}

	public function isErrorEnabled () : Boolean {
		return Log.isError();
	}

	public function isFatalEnabled () : Boolean {
		return Log.isFatal();
	}

	public function trace (message : String, ...params) : void {
		delegate.debug(message, params);
	}

	public function debug (message : String, ...params) : void {
		delegate.debug(message, params);
	}

	public function info (message : String, ...params) : void {
		delegate.info(message, params);
	}

	public function warn (message : String, ...params) : void {
		delegate.warn(message, params); 
	}

	public function error (message : String, ...params) : void {
		delegate.error(message, params);
	}

	public function fatal (message : String, ...params) : void {
		delegate.fatal(message, params);
	}

	
}