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

package org.spicefactory.parsley.flash.resources.tag {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespace;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespaceRegistry;

/**
 * @author Jens Halm
 */
public class FlashResourceXmlSupport {
	
	
	public static const FLASH_RESOURCE_NAMESPACE:String = "http://www.spicefactory.org/parsley/flash/resources";
	
	
	public static function initialize () : void {
		var ns:XmlConfigurationNamespace = XmlConfigurationNamespaceRegistry.registerNamespace(FLASH_RESOURCE_NAMESPACE);
		ns.addDefaultObjectMapper(ResourceBundleTag, "resource-bundle");
		var builder:PropertyMapperBuilder = ns.createObjectMapperBuilder(ResourceManagerTag, "resource-manager");
		builder.mapAllToAttributes();
		builder.createChildElementMapperBuilder("locales", ClassInfo.forClass(LocaleTag)).mapAllToAttributes();
	}
	
	
}
}
