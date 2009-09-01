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

package org.spicefactory.parsley.core.context.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.core.view.ViewManager;

import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Special Context implementation that allows objects to be added and removed dynamically.
 * Will be used internally for any kind of short-lived objects, like views or commands, but can also
 * be used to build custom extensions.
 * 
 * <p>Objects that get added to a Context dynamically behave almost the same like regular managed objects.
 * They can act as receivers or senders of messages, they can have lifecycle listeners and injections can 
 * be performed for them. The only exception is that these objects may not be used as the source of an 
 * injection as they can be added and removed to and from the Context at any point in time so that
 * the validation that comes with dependency injection would not be possible.</p>
 * 
 * @author Jens Halm
 */
public class DynamicContext extends ChildContext {
	
	
	private static const log:Logger = LogContext.getLogger(DynamicContext);

	
	private var objects:Dictionary = new Dictionary();
	

	/**
	 * Creates a new instance.
	 * 
	 * @param parent the Context to be used as the parent for the dynamic Context
	 * @param domain the ApplicationDomain to use for reflection
	 * @param factories the factories to create collaborating services with
	 * @param viewManager the view manager in case this Context should not create its own
	 */
	public function DynamicContext (parent:Context, domain:ApplicationDomain, 
			factories:FactoryRegistry, viewManager:ViewManager = null) {
		super(parent, factories.definitionRegistry.create(domain), factories, null, viewManager);
		addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}

	
	/**
	 * Creates an object from the specified definition and dynamically adds it to the Context.
	 * 
	 * @param definition the definition to create an object from
	 * @return an instance representing the dynamically created object and its defintion
	 */
	public function addDefinition (definition:ObjectDefinition) : DynamicObject {
		checkState();
		var object:DynamicObject = new DynamicObject(this, definition);
		if (object.instance != null) {
			addDynamicObject(object);		
		}
		return object;
	}

	/**
	 * Dynamically adds the specified object to the Context.
	 * 
	 * @param instance the object to add to the Context
	 * @param definition optional definition to apply to the existing instance
	 * @return an instance representing the dynamically created object and its defintion
	 */
	public function addObject (instance:Object, definition:ObjectDefinition = null) : DynamicObject {
		checkState();
		if (definition == null) {
			var ci:ClassInfo = ClassInfo.forInstance(instance, registry.domain);
			var defFactory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(ci.getClass());
			definition = defFactory.createNestedDefinition(registry);
		}
		var object:DynamicObject = new DynamicObject(this, definition, instance);
		addDynamicObject(object);
		return object;
	}
	
	/**
	 * @private
	 */
	internal function addDynamicObject (object:DynamicObject) : void {
		objects[object.instance] = object;	
	}
	
	/**
	 * @private
	 */
	internal function removeDynamicObject (object:DynamicObject) : void {
		if (objects != null) delete objects[object.instance];	
	}
	
	/**
	 * Removes the specified object from the Context. This method may be used
	 * for objects added with <code>addObject</code> as well as for those added with
	 * <code>addDefinition</code>.
	 */
	public function removeObject (instance:Object) : void {
		if (destroyed) return;
		var object:DynamicObject = DynamicObject(objects[instance]);
		if (object != null) {
			object.remove();
		}
	}
	
	private function contextDestroyed (event:Event) : void {
		removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		var remaining:Dictionary = objects;
		objects = null;
		for each (var object:DynamicObject in remaining) {
			object.remove();
		}
	}
	
	private function checkState () : void {
		if (destroyed) {
			throw new IllegalStateError("Attempt to access Context after it was destroyed");
		}
	}
	
	
}
}
