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

package org.spicefactory.parsley.flash.logging {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.flash.logging.FlashLogFactory;
import org.spicefactory.lib.flash.logging.LogLevel;
import org.spicefactory.lib.flash.logging.impl.DefaultLogFactory;
import org.spicefactory.parsley.core.errors.ContextError;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class LogFactoryTag {
	
	
	public var id:String;
	
	public var type:Class = DefaultLogFactory;
	
	public var context:Boolean = true;
	
	public var rootLevel:LogLevel = LogLevel.TRACE;
	
	
	public var appenders:Array;
	
	public var loggers:Array;
	
	
	[Factory]
	public function createLogFactory () : FlashLogFactory {
		var fObj:Object = new type();
		if (!(fObj is FlashLogFactory)) {
			throw new ContextError("Object of type " + getQualifiedClassName(fObj) 
					+ " does not implement FlashLogFactory");
		}
		var factory:FlashLogFactory = fObj as FlashLogFactory;
		factory.setRootLogLevel(rootLevel);
		for each (var appenderTag:AppenderTag in appenders) {
			factory.addAppender(appenderTag.createAppender());
		}
		for each (var loggerTag:LoggerTag in appenders) {
			factory.addLogLevel(loggerTag.name, loggerTag.level);
		}
		factory.refresh();		
		if (context) {
			LogContext.factory = factory;
		}
		return factory;
	}
	
	
}
}
