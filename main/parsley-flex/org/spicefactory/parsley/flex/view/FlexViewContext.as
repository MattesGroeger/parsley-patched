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
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.impl.ChildContext;
import org.spicefactory.parsley.core.impl.ObjectFactory;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class FlexViewContext extends ChildContext {
	
	
	private var definitionMap:Dictionary = new Dictionary();

	
	public function FlexViewContext (parent:Context, registry:ObjectDefinitionRegistry = null, 
			factory:ObjectFactory = null) {
		super(parent, registry, factory);
	}
	
	
	public function addComponent (component:DisplayObject, definition:ObjectDefinition) : void {
		factory.configureObject(component, definition, this);
		definitionMap[component] = definition;
		component.addEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
	}
	
	private function removeComponent (event:Event) : void {
		var component:DisplayObject = DisplayObject(event.target);
		component.removeEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
		var definition:ObjectDefinition = ObjectDefinition(definitionMap[component]);
		if (definition != null) {
			factory.destroyObject(component, definition, this);
		}
	}
	
	
}
}
