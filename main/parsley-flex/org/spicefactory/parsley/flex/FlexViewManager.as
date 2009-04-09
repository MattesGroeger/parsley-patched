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

package org.spicefactory.parsley.flex {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.impl.MetadataObjectDefinitionBuilder;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.flex.view.FlexViewContext;

import mx.core.Application;
import mx.core.UIComponent;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class FlexViewManager {
	
	
	
	private var _triggerEventType:String = "configureIOC";
	
	private var context:FlexViewContext;

	
	function FlexViewManager (triggerEventType:String = null) {
		if (triggerEventType != null) {
			_triggerEventType = triggerEventType;
		}
	}
	
	
	internal function init (parent:Context) : void {
		Application.application.systemManager
				.addEventListener(_triggerEventType, addComponent, true);
		context = new FlexViewContext(parent);
	}

	
	private function addComponent (event:Event) : void {
		var component:UIComponent = UIComponent(event.target);
		component.addEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
		var ci:ClassInfo = ClassInfo.forInstance(component);
		var definition:ObjectDefinition = MetadataObjectDefinitionBuilder.newDefinition(context.registry, ci.getClass());
		context.addComponent(component, definition);
	}

	private function removeComponent (event:Event) : void {
		var component:UIComponent = UIComponent(event.target);
		component.removeEventListener(Event.REMOVED_FROM_STAGE, removeComponent);
		context.removeComponent(component);
	}
	
	
}

}
