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
 
package org.spicefactory.parsley.namespaces.logging {

/**
 * Static constant for the configuration XML that needs to be included
 * with an <code>ApplicationContextParser</code> when using the custom configuration
 * namespace of the MVC Framework.
 * 
 * @author Jens Halm
 */
public class LoggingNamespaceXml {
	
	
	/**
	 * The configuration XML that needs to be included
 	 * with an <code>ApplicationContextParser</code> when using the custom configuration
 	 * namespace of the MVC Framework
	 */
	public static function get config () :XML { 
		// would not be needed when using the SWC, but in Flash CS3 based apps which compile from source
		var a:Class = LogFactoryConfig;
		a = AppenderConfig;
		a = LoggerConfig;
		
		return <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		<setup>
			<namespaces>
				<namespace uri="http://www.spicefactory.org/parsley/1.0/logging">
					<factory-config tag-name="factory" type="org.spicefactory.parsley.namespaces.logging.LogFactoryConfig"/>
					<processor-config tag-name="appender" type="org.spicefactory.parsley.namespaces.logging.AppenderConfig"/>
					<processor-config tag-name="logger" type="org.spicefactory.parsley.namespaces.logging.LoggerConfig"/>
				</namespace>
			</namespaces>
		</setup>
		</application-context>;
	}
	
	
}
}
