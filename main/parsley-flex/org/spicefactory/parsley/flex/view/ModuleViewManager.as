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

package org.spicefactory.parsley.flex.view {
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.registry.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.flex.view.AbstractViewManager;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * ViewManager that handles component wiring for a single Flex Module.
 * 
 * @author Jens Halm
 */
public class ModuleViewManager extends AbstractViewManager {
	
	
	private var context:FlexViewContext;
	private var rootView:DisplayObject;
	
	private var deferredComponents:Array = new Array();
	
	
	/**
	 * Creates a new instance
	 * 
	 * @param rootView the view root of the Flex Module
	 * @param triggerEvent the event type components will use to signal that they wish to get wired
	 */
	function ModuleViewManager (rootView:DisplayObject, triggerEventType:String = null) {
		super(triggerEventType);
		this.rootView = rootView;
		addListener(rootView);
	}

	
	/**
	 * Initializes the view manager for the specfied Context and domain.
	 * 
	 * @param parent the Context to use as a parent for the view Context the components get wired to
	 * @param domain the ApplicationDomain the Module was loaded into
	 */
	public function init (parent:Context, domain:ApplicationDomain) : void {
		context = new FlexViewContext(parent, new DefaultObjectDefinitionRegistry(domain));
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		for each (var component:DisplayObject in deferredComponents) {
			super.addComponent(component);
		}
		deferredComponents = new Array();
	}

	private function contextDestroyed (event:ContextEvent) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		removeListener(rootView);	
	}

	/**
	 * @private
	 */
	protected override function addComponent (component:DisplayObject) : void {
		if (context == null) {
			deferredComponents.push(component);
		}
		else {
			super.addComponent(component);
		}
	}
	
	
	/**
	 * @private
	 */
	protected override function getContext (component:DisplayObject) : FlexViewContext {
		return context;
	}
	
	
}

}
