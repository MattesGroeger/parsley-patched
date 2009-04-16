/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.messaging.decorator {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.metadata.EventInfo;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;

import flash.events.IEventDispatcher;

[Metadata(name="ManagedEvents", types="class")]
/**
 * @author Jens Halm
 */
public class ManagedEventsDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {


	[DefaultProperty]
	public var names:Array;

	
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		if (names == null) {
			names = new Array();
			var events:Array = definition.type.getMetadata(EventInfo);
			for each (var event:EventInfo in events) {
				names.push(event.name);	
			}
		}
		if (names.length == 0) {
			throw new ContextError("ManagedEvents on class " + definition.type.name 
					+ ": No event names specified in ManagedEvents tag and no Event tag on class");	
		}
		definition.lifecycleListeners.addLifecycleListener(this);
		return definition;
	}
	
	public function postConstruct (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		for each (var name:String in names) {		
			eventDispatcher.addEventListener(name, context.messageRouter.dispatchMessage);
		}
	}
	
	public function preDestroy (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		for each (var name:String in names) {		
			eventDispatcher.removeEventListener(name, context.messageRouter.dispatchMessage);
		}
	}

	
}
}


