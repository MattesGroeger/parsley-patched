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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;

import flash.events.Event;
import flash.utils.Dictionary;

/**
 * Special Context implementation that allows objects to be added and removed dynamically.
 * Will be used internally for any kind of short-lived object, like views or commands, but can also
 * be used to build custom extensions.
 * 
 * @author Jens Halm
 */
public class DynamicContext extends ChildContext {
	
	
	private static const log:Logger = LogContext.getLogger(DynamicContext);

	
	private var definitionMap:Dictionary = new Dictionary();
	
	private var deferredObjects:Dictionary = new Dictionary();
	private var deferredDefinitions:Array = new Array();
	

	/**
	 * Creates a new instance.
	 * 
	 * @param parent the Context to be used as the parent for the dynamic Context
	 * @param registry the registry to use
	 * @param factories the factories to create collaborating services with
	 */
	public function DynamicContext (parent:Context, registry:ObjectDefinitionRegistry, 
			factories:FactoryRegistry) {
		super(parent, registry, factories);
		if (!parent.initialized) {
			addEventListener(ContextEvent.INITIALIZED, contextInitialized);
		}
	}
	
	private function contextInitialized (event:Event) : void {
		removeEventListener(ContextEvent.INITIALIZED, contextInitialized);
		for (var instance:Object in deferredObjects) {
			addObject(instance, deferredObjects[instance] as ObjectDefinition);
		}
		for each (var definition:ObjectDefinition in deferredDefinitions) {
			addDefinition(definition);
		}
		deferredObjects = new Dictionary();
		deferredDefinitions = new Array();
	}

	/**
	 * Creates an object from the specified definition and dynamically adds it to the Context.
	 * 
	 * @param definition the definition to create an object from
	 * @return the instance that was created from the defintion and added to the Context
	 */
	public function addDefinition (definition:ObjectDefinition) : Object {
		if (!initialized) {
			deferredDefinitions.push(definition);
			return;			
		}
		var instance:Object = lifecycleManager.createObject(definition, this);
		addObject(instance, definition);
		return instance;
	}

	/**
	 * Dynamically adds the specified object to the Context.
	 * 
	 * @param instance the object to add to the Context
	 * @param definition optional definition to apply to the existing instance
	 */
	public function addObject (instance:Object, definition:ObjectDefinition = null) : void {
		if (definition == null) {
			var ci:ClassInfo = ClassInfo.forInstance(instance, registry.domain);
			var defFactory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(ci.getClass());
			definition = defFactory.createNestedDefinition(registry);
		}
		if (!initialized) {
			deferredObjects[instance] = definition;
			return;			
		}
		lifecycleManager.configureObject(instance, definition, this);
		definitionMap[instance] = definition;
	}
	
	/**
	 * Removes the specified object from the Context. This method may be used
	 * for objects added with <code>addObject</code> as well as for those added with
	 * <code>addDefinition</code>.
	 */
	public function removeObject (instance:Object) : void {
		if (destroyed) return;
		var definition:ObjectDefinition = ObjectDefinition(definitionMap[instance]);
		if (definition != null) {
			lifecycleManager.destroyObject(instance, definition, this);
		}
	}
	
	
}
}
