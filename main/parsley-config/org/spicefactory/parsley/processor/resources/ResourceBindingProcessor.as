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

package org.spicefactory.parsley.processor.resources {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectProcessor;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;
import org.spicefactory.parsley.tag.resources.ResourceBindingAdapter;
import org.spicefactory.parsley.tag.resources.ResourceBindingEvent;

/**
 * Processes a resource binding for a single target property.
 * The resource value will be injected at the time the object is constructed and
 * then each time the corresponding ResourceManager updates.
 * 
 * @author Jens Halm
 */
public class ResourceBindingProcessor implements ObjectProcessor {


	private var target:ManagedObject;
	private var property:Property;

	private var adapter:ResourceBindingAdapter;
	private var key:String;
	private var bundle:String;


	/**
	 * Creates a new processor instance.
	 * 
	 * @param target the target instance to inject the resource into
	 * @param property the target property to inject the resource into
	 * @param adapter the adpater to use to listen for updates
	 * @param key the key for the resource
	 * @param bundle the bundle name 
	 */
	function ResourceBindingProcessor (target:ManagedObject, property:Property, adapter:ResourceBindingAdapter, 
			key:String, bundle:String) {
		this.target = target;
		this.property = property;
		this.adapter = adapter;
		this.key = key;
		this.bundle = bundle;		
	}

	/**
	 * @inheritDoc
	 */
	public function preInit () : void {
		setTarget();
		adapter.addEventListener(ResourceBindingEvent.UPDATE, handleUpdate);
	}

	/**
	 * @inheritDoc
	 */
	public function postDestroy () : void {
		adapter.removeEventListener(ResourceBindingEvent.UPDATE, handleUpdate);
	}

	private function handleUpdate (event:ResourceBindingEvent) : void {
		setTarget();
	}
	
	private function setTarget () : void {
		var resource:* = adapter.getResource(bundle, key);
		property.setValue(target.instance, resource);
	}
	
	
	/**
	 * Creates a new processor factory.
	 * 
	 * @param property the target property to inject the resource into
	 * @param adapter the adpater to use to listen for updates
	 * @param key the key for the resource
	 * @param bundle the bundle name
	 * @return a new processor factory 
	 */
	public static function newFactory (property:Property, adapter:ResourceBindingAdapter, 
			key:String, bundle:String) : ObjectProcessorFactory {
		return ObjectProcessorFactories.newFactory(ResourceBindingProcessor, [property, adapter, key, bundle]);
	}
	
	
}

}
