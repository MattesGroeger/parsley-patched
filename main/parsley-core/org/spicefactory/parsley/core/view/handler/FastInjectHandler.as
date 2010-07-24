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

package org.spicefactory.parsley.core.view.handler {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.events.FastInjectEvent;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.ViewHandler;
import org.spicefactory.parsley.core.view.impl.ViewInjection;
import org.spicefactory.parsley.core.view.util.ContextAwareEventHandler;

import flash.display.DisplayObject;

/**
 * ViewHandler implementation that deals with bubbling events dispatched from FastInject tags.
 * 
 * @author Jens Halm
 */
public class FastInjectHandler implements ViewHandler {


	private var eventHandler:ContextAwareEventHandler;
	
	private var context:Context;
	
	
	/**
	 * @inheritDoc
	 */
	public function init (context:Context, settings:ViewSettings, configurator:ViewConfigurator) : void {
		this.context = context;
		this.eventHandler = new ContextAwareEventHandler(context, processFastInject);
	}

	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		eventHandler.dispose();
	}
	
	/**
	 * @inheritDoc
	 */
	public function addViewRoot (view:DisplayObject) : void {
		view.addEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		view.removeEventListener(FastInjectEvent.FAST_INJECT, handleFastInject);
	}
	
	private function handleFastInject (event:FastInjectEvent) : void {
		event.stopImmediatePropagation();
		if (context.destroyed) return;
		event.markAsProcessed();
		eventHandler.handleEvent(event);
	}
	
	private function processFastInject (event:FastInjectEvent) : void {
		var injections:Array = event.injections;
		for each (var injection:ViewInjection in injections) {
			var target:Object = event.target;
			if ((!injection.objectId && !injection.type) || (injection.objectId && injection.type)) {
				throw new ContextError("Exactly one attribute of type or objectId must be specified");
			}
			var object:Object = (injection.objectId != null)
					? context.getObject(injection.objectId)
					: (injection.type != Context) 
					? context.getObjectByType(injection.type)
					: context;
			target[injection.property] = object;
		}
	}
	
	
}
}
