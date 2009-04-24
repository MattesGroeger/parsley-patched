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

package org.spicefactory.parsley.resources {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ObjectDefinitionBuilderError;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

[Metadata(name="MessageHandler", types="method")]

/**
 * @author Jens Halm
 */
public class ResourceBindingDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {


	public var resourceName:String;

	public var bundleName:String;

	[Target]
	public var property:String;
	

	private static var _adapter:ResourceBindingAdapter;
	
	private static var managedObjects:Dictionary = new Dictionary();
	
	private var _property:Property;
	
	
	private static function initializeAdapter (domain:ApplicationDomain) : void {
		if (_adapter == null) {
			// TODO - init Flex or Flash ResourceAdapter + add listener for ResourceBindingEvent.UPDATE
		}
	}

	
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		initializeAdapter(registry.domain);
		_property = definition.type.getProperty(property);
		if (_property == null) {
			throw new ObjectDefinitionBuilderError("Class " + definition.type.name 
					+ " does not contain a property with name " + _property);
		}
		definition.lifecycleListeners.addLifecycleListener(this);
		return definition;
	}

	public function postConstruct (instance:Object, context:Context) : void {
		_property.setValue(instance, _adapter.getResource(bundleName, resourceName));
		managedObjects[instance] = true;
	}

	public function preDestroy (instance:Object, context:Context) : void {
		delete managedObjects[instance];
	}

	private function handleUpdate (event:ResourceBindingEvent) : void {
		var resource:* = _adapter.getResource(bundleName, resourceName);
		for (var instance:Object in managedObjects) {
			_property.setValue(instance, resource);
		}
	}
	
	
}

}
