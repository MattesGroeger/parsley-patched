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
import org.spicefactory.lib.flash.logging.Appender;
import org.spicefactory.lib.flash.logging.LogLevel;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;

/**
 * @author Jens Halm
 */
public class AppenderTag {
	
	
	[Required]
	public var ref:String;
	
	public var threshold:LogLevel = LogLevel.TRACE;
	
	
	[Inject]
	public var context:Context;
	
	
	public function createAppender () : Appender {
		var appObj:Object = context.getObject(ref);
		if (!(appObj is Appender)) {
			throw new ContextError("Specified object with id " + ref + " does not implement Appender");
		}
		var app:Appender = appObj as Appender;
		app.threshold = threshold;
		return app;
	}
	
	
}
}
