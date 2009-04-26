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

/**
 * A <code>LogFactory</code> is responsible for creating and caching <code>Logger</code> instances
 * and offers configuration options for setting log levels and adding <code>Appender</code> instances.
 * Usually you would not use this interface in application code except for startup logic that configures
 * the factory. The default way to obtain <code>Logger</code> instances is the static
 * <code>LogContext.getLogger</code> method. 
 * 
 * @author Jens Halm
 */	
public interface LogFactory {
	
	/**
	 * Returns the logger for the specified name. If the name parameter is a Class
	 * instance, the fully qualified class name will be used. Otherwise the <code>toString</code>
	 * method will be invoked on the given name instance.
	 * 
	 * @param name the name of the logger
	 * @return the logger for the specified name
	 */
	function getLogger (name:Object) : Logger;
	
}

}