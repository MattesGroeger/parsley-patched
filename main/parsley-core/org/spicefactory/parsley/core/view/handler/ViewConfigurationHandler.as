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
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.ViewRootHandler;
import org.spicefactory.parsley.core.view.util.ContextAwareEventHandler;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * ViewRootHandler implementation that deals with bubbling events from components that explicitly
 * signal that they wish to get wired to the Context.
 * 
 * @author Jens Halm
 */
public class ViewConfigurationHandler implements ViewRootHandler {

	
	private static const LEGACY_CONFIGURE_EVENT:String = "configureIOC";
	private var explicitWireEvent:String = ViewConfigurationEvent.CONFIGURE_VIEW;
	
	private var eventHandler:ContextAwareEventHandler;
	
	private var context:Context;
	private var configurator:ViewConfigurator;
	

	/**
	 * @inheritDoc
	 */	
	public function init (context:Context, settings:ViewSettings, configurator:ViewConfigurator) : void {
		this.context = context;
		this.configurator = configurator;
		this.eventHandler = new ContextAwareEventHandler(context, processConfigurationEvent);
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
		view.addEventListener(explicitWireEvent, handleConfigurationEvent);
		view.addEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		view.removeEventListener(explicitWireEvent, handleConfigurationEvent);
		view.removeEventListener(LEGACY_CONFIGURE_EVENT, handleConfigurationEvent);
	}
	
	
	private function handleConfigurationEvent (event:Event) : void {
		event.stopImmediatePropagation();
		if (event is ViewConfigurationEvent) {
			ViewConfigurationEvent(event).markAsProcessed();
		}
		eventHandler.handleEvent(event);
	}
	
	private function processConfigurationEvent (event:Event) : void {
		var configTarget:Object = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configTarget : event.target;
		var configId:String = (event is ViewConfigurationEvent) 
				? ViewConfigurationEvent(event).configId 
				: (configTarget is DisplayObject) ? DisplayObject(configTarget).name : null;
		if (configurator.isConfigured(configTarget)) return;
		configurator.configure(configTarget, configurator.getDefinition(configTarget, configId));
	}
	
	
}
}
