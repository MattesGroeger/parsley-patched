/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.xml.mapper {
import org.spicefactory.lib.xml.mapper.XmlObjectMappings;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * The central registry for custom XML configuration namespaces.
 * 
 * Namespaces have to be created and configured before the first XML configuration file containing tags from
 * that namespace gets loaded.
 * 
 * @author Jens Halm
 */
public class XmlConfigurationNamespaceRegistry {
	

	private static const namespaces:Dictionary = new Dictionary();	

	
	/**
	 * Registers a new XML configuration namespace for the specified URI.
	 * The instance returned by this namespace can be used to configure the namespace,
	 * adding XML-to-Object Mappers for the custom tags. The <code>XmlObjectMappings</code>
	 * class offers the core configuration DSL for the Spicelib XML-Object-Mapper.
	 * 
	 * @param uri the URI of the custom XML configuration namespace
	 * @param domain the ApplicationDomain to use for reflection
	 * @return an instance that can be used to configure the namespace
	 */
	public static function registerNamespace (uri:String, domain:ApplicationDomain = null) : XmlObjectMappings {
		if (namespaces[uri] == undefined) {
			namespaces[uri] = new CustomNamespaceMappings(uri, domain);
		}
		return namespaces[uri];
	}
	
	/**
	 * Returns all custom XML configuration namespaces that have been added to the registry.
	 * 
	 * @return all custom XML configuration namespaces that have been added to the registry
	 */
	public static function getRegisteredNamespaces () : Array {
		var result:Array = new Array();
		for each (var ns:XmlObjectMappings in namespaces) {
			result.push(ns);
		}
		return result;
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.XmlObjectMappings;
import org.spicefactory.parsley.config.NestedConfigurationElement;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.tag.core.ObjectDecoratorMarker;

import flash.system.ApplicationDomain;

class CustomNamespaceMappings extends XmlObjectMappings {

	function CustomNamespaceMappings (uri:String, domain:ApplicationDomain) {
		super(uri, domain);
	}
	
	protected override function postProcess (mappers:Array) : void {
		for each (var mapper:XmlObjectMapper in mappers) {
			var type:ClassInfo = mapper.objectType;
			
			if (type.isType(ObjectDecoratorMarker)) {
				choiceId("decorators", type.getClass()); // TODO - use constants
			}
			
			if (type.isType(RootConfigurationElement)) {
				choiceId("rootElements", type.getClass());
			}
			
			if (type.isType(NestedConfigurationElement)) {
				choiceId("nestedElements", type.getClass());
			}
			
			if (!type.isType(ObjectDecoratorMarker)) {
				if (!type.isType(RootConfigurationElement)) {
					choiceId("rootElements", type.getClass());
				}
				if (!type.isType(NestedConfigurationElement)) {
					choiceId("nestedElements", type.getClass());
				}
			}
		}
	}
	
}


