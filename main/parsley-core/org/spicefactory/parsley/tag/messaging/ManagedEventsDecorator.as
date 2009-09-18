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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.lib.reflect.metadata.EventInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.messaging.impl.MessageDispatcherFunctionReference;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.definition.ObjectLifecycleListener;
import org.spicefactory.parsley.tag.core.NestedTag;

import flash.events.IEventDispatcher;

[Metadata(name="ManagedEvents", types="class", multiple="true")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on classes that dispatch events
 * that should be dispatched through Parsleys central message router.
 * 
 * May only be place on classes that implement <code>IEventDispatcher</code>. The class definition
 * should contain additional regular <code>[Event]</code> tags for all events it dispatches.
 * 
 * <p>This <code>ObjectDefinitionDecorator</code> adds itself to the processed definiton as an <code>ObjectLifecycleListener</code>,
 * thus both interfaces are implemented.</p>
 *
 * @author Jens Halm
 */
public class ManagedEventsDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener, NestedTag {


	[DefaultProperty]
	/**
	 * The event names/types of all events dispatched by the annotated class that should be mamaged by Parsley.
	 */
	public var names:Array;
	
	private var delegate:MessageDispatcherFunctionReference;

	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		delegate = new MessageDispatcherFunctionReference();
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
	
	/**
	 * @inheritDoc
	 */
	public function postConstruct (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		if (delegate.router == null) delegate.router = context.messageRouter;
		for each (var name:String in names) {		
			eventDispatcher.addEventListener(name, delegate.dispatchMessage);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function preDestroy (instance:Object, context:Context) : void {
		var eventDispatcher:IEventDispatcher = IEventDispatcher(instance);
		for each (var name:String in names) {		
			eventDispatcher.removeEventListener(name, delegate.dispatchMessage);
		}
	}

	
}
}


