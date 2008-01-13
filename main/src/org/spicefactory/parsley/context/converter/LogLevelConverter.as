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
 
package org.spicefactory.parsley.context.converter {
import org.spicefactory.lib.logging.LogLevel;
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.parsley.context.ConfigurationError;	

/**
 * Converter implementation that converts strings to <code>LogLevel</code> instances.
 * 
 * @author Jens Halm
 */
public class LogLevelConverter  implements Converter {
	
	
	public static const INSTANCE:LogLevelConverter = new LogLevelConverter(); 

	/**
	 * @private
	 */
	public function LogLevelConverter () {
		
	}

	/**
	 * @inheritDoc
	 */
	public function convert (value:*) : * {
		var level:LogLevel = LogLevel[value.toString().toUpperCase()];
		if (level == null) {
			throw new ConfigurationError("Illegal value for log level: " + value);
		}
		return level;
	}
	

}

}