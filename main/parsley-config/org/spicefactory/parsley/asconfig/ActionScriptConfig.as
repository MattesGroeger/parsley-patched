/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.asconfig {
import org.spicefactory.parsley.asconfig.processor.ActionScriptConfigurationProcessor;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;

/**
 * Static entry point methods for creating ActionScript configuration processors to be added to a ContextBuilder.
 * 
 * <p>Example:</p>
 * <pre><code>ContextBuilder
 *     .newInstance()
 *     .config(ActionScriptConfig.forClass(MyConfig))
 *     .build();</code></pre>
 * 
 * <p>For details on ActionScript configuration see 
 * <a href="http://www.spicefactory.org/parsley/docs/2.3/manual?page=config&section=as3">3.6 ActionScript Configuration</a>
 * in the Parsley Manual.</p>
 * 
 * @author Jens Halm
 */
public class ActionScriptConfig {
	
	
	/**
	 * Creates a processor for the specified ActionScript configuration class.
	 * 
	 * @param configClass the class that contains the ActionScript configuration
	 * @return a new configuration processor instance which can be added to a ContextBuilder
	 */
	public static function forClass (configClass:Class) : ConfigurationProcessor {
		return new ActionScriptConfigurationProcessor([configClass]);	
	}
	
	/**
	 * Creates a processor for the specified ActionScript configuration classes.
	 * 
	 * @param configClasses the classes that contain the ActionScript configuration
	 * @return a new configuration processor instance which can be added to a ContextBuilder
	 */
	public static function forClasses (...configClasses) : ConfigurationProcessor {
		return new ActionScriptConfigurationProcessor(configClasses);
	}
	
	
}
}

