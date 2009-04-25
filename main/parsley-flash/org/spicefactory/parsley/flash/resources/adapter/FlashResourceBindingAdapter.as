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

package org.spicefactory.parsley.flash.resources.adapter {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent;
import org.spicefactory.parsley.flash.resources.ResourceManager;
import org.spicefactory.parsley.resources.ResourceBindingEvent;
import org.spicefactory.parsley.resources.ResourceBindingAdapter;


import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class FlashResourceBindingAdapter extends EventDispatcher implements ResourceBindingAdapter {


	public static var manager:ResourceManager;

	
	private var initialized:Boolean = false;
	
	
	private function init () : void {
		initialized = true;
		manager.addEventListener(LocaleSwitchEvent.COMPLETE, dispatchUpdateEvent);
	}
	
	private function dispatchUpdateEvent (event:Event) : void {
		dispatchEvent(new ResourceBindingEvent(ResourceBindingEvent.UPDATE));
	}
	
	public function getResource (bundleName:String, resourceName:String) : * {
		if (manager == null) {
			throw new IllegalStateError("ResourceManager has not been set for this adapter");
		}
		if (!initialized) {
			init(); // we wait until the first resource get accessed since we assume the ResourceManager has been set before
		}
		return manager.getMessage(resourceName, bundleName);
	}
	
	
}
}
