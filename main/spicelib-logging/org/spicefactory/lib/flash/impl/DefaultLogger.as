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
 * 
 * @author Jens Halm
 */
 
package org.spicefactory.lib.flash.impl {
import flash.events.EventDispatcher;

import org.spicefactory.lib.flash.logging.LogEvent;
import org.spicefactory.lib.flash.logging.LogLevel;
import org.spicefactory.lib.flash.logging.Logger;	


/**
 * Dispatched when any of the logging methods is invoked.
 * 
 * @eventType org.spicefactory.lib.logging.LogEvent.LOG
 */
[Event(name="log", type="org.spicefactory.lib.logging.LogEvent")]


/**
 * The default Logger implementation that dispatches <code>LogEvents</code> for all
 * logging operations.
 */
public class DefaultLogger extends EventDispatcher implements Logger {


	private var _name:String;
	private var _level:LogLevel;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param name the name of this Logger
	 * @param level the log level of this Logger
	 */
	public function DefaultLogger (name:String, level:LogLevel) {
		_name = name;
		_level = level;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get name () : String {
		return _name;
	}

	/**
	 * @inheritDoc
	 */	
	public function get level () : LogLevel {
		return _level;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set level (level:LogLevel) : void {
		_level = level;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isTraceEnabled () : Boolean {
		return (level.toValue() <= LogLevel.TRACE.toValue());
	}
	
	/**
	 * @inheritDoc
	 */
	public function isDebugEnabled () : Boolean {
		return (level.toValue() <= LogLevel.DEBUG.toValue());
	}
	
	/**
	 * @inheritDoc
	 */
	public function isInfoEnabled () : Boolean {
		return (level.toValue() <= LogLevel.INFO.toValue());
	}
	
	/**
	 * @inheritDoc
	 */
	public function isWarnEnabled () : Boolean {
		return (level.toValue() <= LogLevel.WARN.toValue());
	}
	
	/**
	 * @inheritDoc
	 */
	public function isErrorEnabled () : Boolean {
		return (level.toValue() <= LogLevel.ERROR.toValue());
	}
	
	/**
	 * @inheritDoc
	 */
	public function isFatalEnabled () : Boolean {
		return (level.toValue() <= LogLevel.FATAL.toValue());
	}

	/**
	 * @inheritDoc
	 */
	public function trace (message:String, error:Error = null) : void {
		if (!isTraceEnabled()) return;
		dispatch(LogLevel.TRACE, message, error);
	}
	
	/**
	 * @inheritDoc
	 */
	public function debug (message:String, error:Error = null) : void {
		if (!isDebugEnabled()) return;
		dispatch(LogLevel.DEBUG, message, error);
	}
	
	/**
	 * @inheritDoc
	 */
	public function info (message:String, error:Error = null) : void {
		if (!isInfoEnabled()) return;
		dispatch(LogLevel.INFO, message, error);
	}
	
	/**
	 * @inheritDoc
	 */
	public function warn (message:String, error:Error = null) : void {
		if (!isWarnEnabled()) return;
		dispatch(LogLevel.WARN, message, error);
	}
	
	/**
	 * @inheritDoc
	 */
	public function error (message:String, error:Error = null) : void {
		if (!isErrorEnabled()) return;
		dispatch(LogLevel.ERROR, message, error);
	}
	
	/**
	 * @inheritDoc
	 */
	public function fatal (message:String, error:Error = null) : void {
		if (!isFatalEnabled()) return;
		dispatch(LogLevel.FATAL, message, error);
	}
	
	private function dispatch (level:LogLevel, message:String, error:Error) : void {
		dispatchEvent(new LogEvent(level, message, error));
	} 
		
		
}

}
