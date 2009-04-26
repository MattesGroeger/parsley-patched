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
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.flash.resources.impl.DefaultBundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.impl.DefaultResourceBundle;
import org.spicefactory.parsley.flash.resources.spi.BundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
[AsyncInit(order="-2147483648")]
public class ResourceBundleTag extends EventDispatcher {
	
	
	[Required]
	public var id:String;
	
	[Required]
	public var basename:String;


	public var type:Class = DefaultResourceBundle;
	
	public var loaderFactory:Class = DefaultBundleLoaderFactory;
	
	public var localized:Boolean = true;
	
	public var ignoreCountry:Boolean = false;
	
	
	[Inject]
	public var resourceManager:ResourceManagerSpi;
	
	
	[PostConstruct]
	public function loadBundle () : void {
		var bundleInstance:Object = new type();
		if (!(bundleInstance is ResourceBundleSpi)) {
			throw new IllegalArgumentError("Specified type " + getQualifiedClassName(type) 
					+ " does not implement ResourceBundleSpi"); 
		}
		var bundle:ResourceBundleSpi = bundleInstance as ResourceBundleSpi;
		var factoryInstance:Object = new loaderFactory();
		if (!(bundleInstance is BundleLoaderFactory)) {
			throw new IllegalArgumentError("Specified loaderFactory " + getQualifiedClassName(type) 
					+ " does not implement BundleLoaderFactory"); 
		}
		bundle.bundleLoaderFactory = factoryInstance as BundleLoaderFactory;
		bundle.init(id, basename, localized, ignoreCountry);
		
		var tg:TaskGroup = new SequentialTaskGroup();
		tg.data = bundle;
		bundle.addLoaders(resourceManager.currentLocale, tg);
		tg.addEventListener(TaskEvent.COMPLETE, loaderComplete);
		tg.addEventListener(ErrorEvent.ERROR, loaderError);
	}
	
	
	private function loaderComplete (event:Event) : void {
		var bundle:ResourceBundleSpi = event.target.data as ResourceBundleSpi;
		bundle.applyNewMessages();
		resourceManager.addBundle(bundle);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function loaderError (event:Event) : void {
		dispatchEvent(event.clone());
	}
	
	
}
}
