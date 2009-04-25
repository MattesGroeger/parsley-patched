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
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.impl.DefaultRootObjectDefinition;
import org.spicefactory.parsley.flash.resources.impl.DefaultResourceManager;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;
import org.spicefactory.parsley.util.IdGenerator;

import flash.errors.IllegalOperationError;
import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class ResourceManagerTag implements ObjectDefinitionFactory {
	
	
	public var locales:Array;
	
	public var type:Class = DefaultResourceManager;
	
	public var cacheable:Boolean = false;

	public var persistent:Boolean = false;
	
	
	
	public function createRootDefinition (registry:ObjectDefinitionRegistry) : RootObjectDefinition {
		var typeInfo:ClassInfo = ClassInfo.forClass(type, registry.domain);
		if (!typeInfo.isType(ResourceManagerSpi)) {
			throw new IllegalArgumentError("Specified type " + getQualifiedClassName(type) 
					+ " does not implement ResourceManagerSpi"); 
		}
		var definition:RootObjectDefinition = new DefaultRootObjectDefinition(typeInfo, IdGenerator.nextObjectId); // TODO - id should be optional
		definition.properties.addValue("persistent", persistent);
		definition.properties.addValue("cacheable", cacheable);
		definition.lifecycleListeners.addLifecycleListener(new ResourceManagerLifecycleListener(locales));
	}
	
	public function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		throw new IllegalOperationError("ResourceManager Tag can only be used for root object definitions");
	}
}
}

import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.ResourceManager;
import org.spicefactory.parsley.flash.resources.adapter.FlashResourceBindingAdapter;

class ResourceManagerLifecycleListener implements ObjectLifecycleListener {

	private var locales:Array;

	function ResourceManagerLifecycleListener (locales:Array) { this.locales = locales; }

	public function postConstruct (instance:Object, context:Context) : void {
		var rm:ResourceManager = instance as ResourceManager;
		
		FlashResourceBindingAdapter.manager = rm;
		
		var first:Boolean = true;
		for each (var locTag:LocaleTag in locales) {
			var loc:Locale = new Locale(locTag.language, locTag.country);
			if (first) {
				first = false;
				rm.defaultLocale = loc;
			}
			else {
				rm.addSupportedLocale(loc);
			}
		}
	}
	
	public function preDestroy (instance:Object, context:Context) : void { /* do nothing */	}
	
}
