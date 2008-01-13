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
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.core.enum.AutowireMode;

/**
 * Converter implementation that converts strings to <code>Autowire</code> enumeration instances.
 * 
 * @author Jens Halm
 */
public class AutowireConverter  implements Converter {
	
	
	public static const INSTANCE:AutowireConverter = new AutowireConverter(); 

	/**
	 * @private
	 */
	public function AutowireConverter () {
		
	}

	/**
	 * @inheritDoc
	 */
	public function convert (value:*) : * {
		switch (value.toString()) {
			case "by-type": 
				return AutowireMode.BY_TYPE;
			case "by-name":
				return AutowireMode.BY_NAME;
			case "off":
				return AutowireMode.OFF;
			default:
				throw new ConfigurationError("Illegal value for log level: " + value);
		}
		return null;
	}
	

}

}