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
import org.spicefactory.parsley.core.events.ViewAutowireEvent;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.view.ViewAutowireMode;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.ViewHandler;
import org.spicefactory.parsley.core.view.util.ContextAwareEventHandler;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * ViewHandler implementation that deals with autowiring views to the Context.
 * 
 * @author Jens Halm
 */
public class ViewAutowireHandler implements ViewHandler {


	private var context:Context;
	private var configurator:ViewConfigurator;
	private var settings:ViewSettings;
	
	private var eventHandler:ContextAwareEventHandler;
	
	
	/**
	 * @inheritDoc
	 */
	public function init (context:Context, settings:ViewSettings, configurator:ViewConfigurator) : void {
		this.context = context;
		this.settings = settings;
		this.configurator = configurator;
		this.eventHandler = new ContextAwareEventHandler(context, processAutowireEvent);
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
		if (settings.autowireComponents) {
			view.addEventListener(settings.autowireFilter.eventType, prefilterView, true);
			view.addEventListener(settings.autowireFilter.eventType, prefilterView);
			view.addEventListener(ViewAutowireEvent.AUTOWIRE, handleAutowireEvent);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		if (settings.autowireComponents) {
			view.removeEventListener(settings.autowireFilter.eventType, prefilterView, true);
			view.removeEventListener(settings.autowireFilter.eventType, prefilterView);
			view.removeEventListener(ViewAutowireEvent.AUTOWIRE, handleAutowireEvent);
		}
	}
	
	private function prefilterView (event:Event) : void {
		if (!AutowirePrefilterCache.addEvent(event)) return;
		var view:DisplayObject = event.target as DisplayObject;
		if (settings.autowireFilter.prefilter(view)) {
			view.dispatchEvent(new ViewAutowireEvent());
		}
	}
	
	private function handleAutowireEvent (event:Event) : void {
		event.stopImmediatePropagation();
		if (configurator.isConfigured(event.target)) return;
		eventHandler.handleEvent(event);
	}

	private function processAutowireEvent (event:Event) : void {
		var view:DisplayObject = event.target as DisplayObject;
		if (configurator.isConfigured(view)) return;
		var mode:ViewAutowireMode = settings.autowireFilter.filter(view);
		if (mode == ViewAutowireMode.ALWAYS) {
			configurator.configure(view, configurator.getDefinition(view, view.name));
		}
		else if (mode == ViewAutowireMode.CONFIGURED) {
			var definition:DynamicObjectDefinition = configurator.getDefinition(view, view.name);
			if (definition != null) {
				configurator.configure(view, definition);
			}
		}
	}
	
	
}
}
