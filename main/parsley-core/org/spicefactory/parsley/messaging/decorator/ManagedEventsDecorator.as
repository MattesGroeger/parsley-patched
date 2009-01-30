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
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

[Metadata(name="ManagedEvents", types="class")]
/**
 * @author Jens Halm
 */
public class ManagedEventsDecorator implements ObjectDefinitionDecorator {


	[DefaultProperty]
	public var names:Array;

	[Target]
	public var type:ClassInfo;
	
	
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		if (names == null) {
			names = new Array();
			var events:Array = type.getMetadata(EventInfo);
			for each (var event:EventInfo in events) {
				names.push(event.name);	
			}
		}
		if (names.length == 0) {
			throw new ContextError("ManagedEvents on class " + type.name 
					+ ": No event names specified in ManagedEvents tag and no Event tag on class");	
		}
		definition.postProcessors.addPostProcessor(new ManagedEventsPostProcessor(names));
	}
}
}

import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.ObjectPostProcessor;

import flash.events.IEventDispatcher;

class ManagedEventsPostProcessor implements ObjectPostProcessor {

	private var names:Array;

	function ManagedEventsPostProcessor (names:Array) {
		this.names = names;
	}

	public function process (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		for each (var name:String in names) {		
			eventDispatcher.addEventListener(name, context.messageDispatcher.dispatchMessage);
		}
		context.addDestroyCommand(new Command(onDestroy, [instance, context]));
	}
	
	private function onDestroy (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		for each (var name:String in names) {		
			eventDispatcher.addEventListener(name, context.messageDispatcher.dispatchMessage);
		}
	}
	
	
}
