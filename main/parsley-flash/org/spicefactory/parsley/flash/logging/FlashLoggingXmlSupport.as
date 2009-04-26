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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespace;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespaceRegistry;

/**
 * @author Jens Halm
 */
public class FlashLoggingXmlSupport {
	
	
	public static const FLASH_LOGGING_NAMESPACE:String = "http://www.spicefactory.org/parsley/flash/logging";
	
	
	public static function initialize () : void {
		var ns:XmlConfigurationNamespace = XmlConfigurationNamespaceRegistry.registerNamespace(FLASH_LOGGING_NAMESPACE);
		var builder:PropertyMapperBuilder = ns.createObjectMapperBuilder(LogFactoryTag, "factory");
		builder.mapAllToAttributes();
		builder.createChildElementMapperBuilder("appenders", ClassInfo.forClass(AppenderTag)).mapAllToAttributes();
		builder.createChildElementMapperBuilder("loggers", ClassInfo.forClass(LoggerTag)).mapAllToAttributes();
	}
	
	
}
}
