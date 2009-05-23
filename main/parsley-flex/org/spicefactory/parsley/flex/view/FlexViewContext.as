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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.impl.ChildContext;
import org.spicefactory.parsley.core.impl.ObjectFactory;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class FlexViewContext extends ChildContext {
	
	
	private static const log:Logger = LogContext.getLogger(FlexViewContext);

	
	private var definitionMap:Dictionary = new Dictionary();
	
	private var deferredComponents:Array = new Array();
	

	
	public function FlexViewContext (parent:Context, registry:ObjectDefinitionRegistry = null, 
			factory:ObjectFactory = null) {
		super(parent, registry, factory);
		addEventListener(ContextEvent.INITIALIZED, contextInitialized);
		initialize();
	}
	
	private function contextInitialized (event:Event) : void {
		for each (var component:DisplayObject in deferredComponents) {
			addComponent(component);
		}
		deferredComponents = new Array();
	}

	public function addComponent (component:DisplayObject) : void {
		if (!initialized) {
			deferredComponents.push(component);
			return;			
		}
		var ci:ClassInfo = ClassInfo.forInstance(component, registry.domain);
		var defFactory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(ci.getClass());
		try {
			var definition:ObjectDefinition = defFactory.createNestedDefinition(registry);
			factory.configureObject(component, definition, this);
			definitionMap[component] = definition;
			component.addEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
		}
		catch (e:Error) {
			log.error("Error adding Component {0} to Context {1}", component, e);
		}
	}
	
	private function removeComponent (event:Event) : void {
		if (destroyed) return;
		var component:DisplayObject = DisplayObject(event.target);
		log.debug("Remove component '{0}' from ViewContext", component);
		component.removeEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
		var definition:ObjectDefinition = ObjectDefinition(definitionMap[component]);
		if (definition != null) {
			factory.destroyObject(component, definition, this);
		}
	}
	
	
}
}
