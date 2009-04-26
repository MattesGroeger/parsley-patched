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

package org.spicefactory.parsley.flex.logging {
import org.spicefactory.parsley.core.errors.ContextError;

import mx.logging.ILoggingTarget;
import mx.logging.Log;
import mx.logging.LogEventLevel;
import mx.logging.targets.LineFormattedTarget;
import mx.logging.targets.TraceTarget;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class LogTargetTag {
	
	
	public var type:Class = TraceTarget;
	
	public var filters:Array;
	
	public var level:int = LogEventLevel.ALL;
	
	
	public var fieldSeparator:String = " ";
	
	public var includeCategory:Boolean = true;
	
	public var includeLevel:Boolean = true;
	
	public var includeDate:Boolean = true;
	
	public var includeTime:Boolean = true;
	
	
	[Factory]
	public function createLogFactory () : ILoggingTarget {
		var targetObj:Object = new type();
		if (!(targetObj is ILoggingTarget)) {
			throw new ContextError("Object of type " + getQualifiedClassName(targetObj) 
					+ " does not implement ILoggingTarget");
		}
		var target:ILoggingTarget = targetObj as ILoggingTarget;
		if (filters != null) target.filters = filters;
		target.level = level;
		
		if (target is LineFormattedTarget) {
			var lfTarget:LineFormattedTarget = target as LineFormattedTarget;
			lfTarget.fieldSeparator = fieldSeparator;
			lfTarget.includeCategory = includeCategory;
			lfTarget.includeLevel = includeLevel;
			lfTarget.includeDate = includeDate;
			lfTarget.includeTime = includeTime;
		}
		
		Log.addTarget(target);
		return target;
	}
	
	
}
}
