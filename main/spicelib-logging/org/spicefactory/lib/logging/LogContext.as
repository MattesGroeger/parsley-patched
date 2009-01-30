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
 
package org.spicefactory.lib.logging {

import org.spicefactory.lib.logging.impl.DelegateLogger;
import org.spicefactory.lib.logging.impl.DefaultLogFactory;
import org.spicefactory.lib.logging.impl.TraceAppender;
	

/**
 * Central entry point to the Logging Framework. The static <code>getLogger</code> method
 * is the default way for obtaining a <code>Logger</code> instance. While 
 * the correspondig <code>getLogger</code> method on a <code>LogFactory</code> instance
 * could also be used, using the <code>LogContext</code> is more convenient and the only way
 * to align the Loggers of custom application code with the log output of Spicefactory libraries,
 * since all Spicefactory classes use the <code>LogContext</code> internally to obtain Logger instances.
 * 
 * <p>Per default <code>LogContext</code> uses an instance of <code>DefaultLogFactory</code>
 * internally. But using the static <code>factory</code> property you could switch to a
 * custom <code>LogFactory</code> implementation if necessary. You could even switch at
 * runtime and all existing <code>Logger</code> instances obtained through <code>LogContext</code>
 * will be refreshed with instances from the new factory.
 * 
 * @author Jens Halm
 */
public class LogContext {
	
	
	private static var _factory:LogFactory;
	
	private static var loggers:Object = new Object();
	
	
	/**
	 * Returns the logger for the specified name. If the name parameter is a Class
	 * instance, the fully qualified class name will be used. Otherwise the <code>toString</code>
	 * method will be invoked on the given name instance.
	 * 
	 * @param name the name of the logger
	 * @return the logger for the specified name
	 */
	public static function getLogger (name:Object) : Logger {
		var nameStr:String = LogUtil.getLogName(name);
		if (loggers[nameStr] != null) {
			return loggers[nameStr];
		}
		var log:Logger = factory.getLogger(nameStr);
		var del:DelegateLogger = new DelegateLogger(log);
		loggers[nameStr] = del;
		return del;
	}
	
	/**
	 * The LogFactory for the global LogContext.
	 * This is the factory that will be used for all Loggers obtained with
	 * <code>LogContext.getLogger</code>. If you later switch to a different LogFactory
	 * all Loggers obtained with that method will be refreshed to use Logger instances
	 * from the new factory.
	 */
	public static function get factory () : LogFactory {
		if (_factory == null) {
			createDefaultFactory();
		}
		return _factory;
	}
	
	public static function set factory (factory:LogFactory) : void {
		_factory = factory;
		refreshDelegates();
	}
	
	
	private static function refreshDelegates () : void {
		for each (var log:DelegateLogger in loggers) {
			log.delegate = _factory.getLogger(log.name);
		}
	}
	
	private static function createDefaultFactory () : void {
		_factory = new DefaultLogFactory();
		_factory.addAppender(new TraceAppender());
	}
	
}
	
}