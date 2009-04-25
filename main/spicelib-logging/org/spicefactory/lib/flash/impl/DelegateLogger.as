/*
 * Copyright 2007 the original author or authors.
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
 
package org.spicefactory.lib.flash.impl {
	
import org.spicefactory.lib.flash.logging.Logger;
import org.spicefactory.lib.flash.logging.LogLevel;
import flash.events.Event;
	

/**	
 * Logger implementation that delegates all logging operations to a different Logger
 * instance. Spicelib uses this class internally for Loggers created with 
 * <code>LogContext.getLogger</code>
 * so that the Logger implementation that does the actual work can be switched dynamically.
 * Usually this class is not used by application code.
 * 
 * @author Jens Halm
 */
public class DelegateLogger implements Logger {
		
	
	private var _delegate:Logger;
	
	
	/**
	 * Creates a new instance using the specified Logger as the delegate.
	 * 
	 * @param log the Logger instance to use as a delegate
	 */
	public function DelegateLogger (log:Logger) {
		_delegate = log;
	}
	
	/**
	 * The Logger instance to use as a delegate.
	 */
	public function get delegate () : Logger {
		return _delegate;
	}
	
	public function set delegate (log:Logger) : void {
		_delegate = log;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get name () : String {
		return _delegate.name;
	}

	/**
	 * @inheritDoc
	 */
	public function get level () : LogLevel {
		return _delegate.level;
	}

	public function set level (level : LogLevel) : void {
		_delegate.level = level;
	}

	/**
	 * @inheritDoc
	 */
	public function isTraceEnabled () : Boolean {
		return _delegate.isTraceEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function isDebugEnabled() : Boolean {
		return _delegate.isDebugEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function isInfoEnabled() : Boolean {
		return _delegate.isInfoEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function isWarnEnabled() : Boolean {
		return _delegate.isWarnEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function isErrorEnabled() : Boolean {
		return _delegate.isErrorEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function isFatalEnabled() : Boolean {
		return _delegate.isFatalEnabled();
	}

	/**
	 * @inheritDoc
	 */
	public function trace (log : String, error:Error = null) : void {
		_delegate.trace(log, error);
	}

	/**
	 * @inheritDoc
	 */
	public function debug(log : String, error:Error = null) : void {
		_delegate.debug(log, error);
	}

	/**
	 * @inheritDoc
	 */
	public function info(log : String, error:Error = null) : void {
		_delegate.info(log, error);
	}

	/**
	 * @inheritDoc
	 */
	public function warn(log : String, error:Error = null) : void {
		_delegate.warn(log, error);
	}

	/**
	 * @inheritDoc
	 */
	public function error(log : String, error:Error = null) : void {
		_delegate.error(log, error);
	}

	/**
	 * @inheritDoc
	 */
	public function fatal(log : String, error:Error = null) : void {
		_delegate.fatal(log, error);
	}		
	
	/**
	 * @private
	 */
	public function hasEventListener (type:String) : Boolean {
		return _delegate.hasEventListener(type);
	}
	
	/**
	 * @private
	 */
	public function willTrigger (type:String) : Boolean {
		return _delegate.willTrigger(type);
	}
	
	/**
	 * @private
	 */
	public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false) : void {
		_delegate.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	/**
	 * @private
	 */
	public function removeEventListener (type:String, listener:Function, useCapture:Boolean=false) : void {
		_delegate.removeEventListener(type, listener, useCapture);
	}
	
	/**
	 * @private
	 */
	public function dispatchEvent (event:Event) : Boolean {
		return _delegate.dispatchEvent(event);
	}	
		
}
	
}