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

package org.spicefactory.parsley.core.lifecycle.impl {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.impl.MessageDispatcherFunctionReference;
import org.spicefactory.parsley.core.registry.definition.ObjectLifecycleListener;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.model.ObjectIdReference;
import org.spicefactory.parsley.core.registry.model.ObjectTypeReference;
import org.spicefactory.parsley.core.registry.model.ManagedArray;
import org.spicefactory.parsley.core.registry.model.PropertyValue;
import org.spicefactory.parsley.core.registry.definition.MethodParameterRegistry;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the ObjectFactory interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectLifecycleManager implements ObjectLifecycleManager {
	
	
	private var processedInstances:Dictionary = new Dictionary();

	private var domain:ApplicationDomain;


	/**
	 * Creates a new instance.
	 * 
	 * @param domain the ApplicationDomain to use for reflection
	 */
	function DefaultObjectLifecycleManager (domain:ApplicationDomain) {
		this.domain = domain;		
	}


	/**
	 * @inheritDoc
	 */
	public function createObject (definition:ObjectDefinition, context:Context) : Object {
		if (definition.instantiator != null) {
			return definition.instantiator.instantiate(context);
		}
		else {
			var args:Array = resolveArray(definition.constructorArgs.getAll(), context);
			return definition.type.newInstance(args);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function configureObject (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	processProperties(instance, definition, context);
	 	processMethods(instance, definition, context);
	 	processPostConstructListeners(instance, definition, context);
		processedInstances[instance] = definition;
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroyObject (instance:Object, definition:ObjectDefinition, context:Context) : void {
		processPreDestroyListeners(instance, definition, context);
		delete processedInstances[instance];
	}

	/**
	 * @inheritDoc
	 */
	public function destroyAll (context:Context) : void {
		for (var instance:Object in processedInstances) {
			var definition:ObjectDefinition = ObjectDefinition(processedInstances[instance]);
			processPreDestroyListeners(instance, definition, context);
		}
		processedInstances = new Dictionary();
	}
	
	/**
	 * Processes the configuration of the properties for the specified instance.
	 * 
	 * @param instance the instance to process
	 * @param definition the definition of the specified instance
	 * @param context the Context the instance belongs to
	 */
	protected function processProperties (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var props:Array = definition.properties.getAll();
	 	for each (var prop:PropertyValue in props) {
	 		var value:* = resolveValue(prop.value, context);
	 		prop.property.setValue(instance, value);
		}		
	}

	/**
	 * Processes the configuration of the methods for the specified instance, performing method injection.
	 * 
	 * @param instance the instance to process
	 * @param definition the definition of the specified instance
	 * @param context the Context the instance belongs to
	 */	
	protected function processMethods (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var methods:Array = definition.injectorMethods.getAll();
	 	for each (var mpr:MethodParameterRegistry in methods) {
			var params:Array = resolveArray(mpr.getAll(), context);
	 		mpr.method.invoke(instance, params);
		}		
	}
	
	/**
	 * Processes the lifecycle listeners for the specified instance after it has been created.
	 * 
	 * @param instance the instance to process
	 * @param definition the definition of the specified instance
	 * @param context the Context the instance belongs to
	 */
	protected function processPostConstructListeners (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var listeners:Array = definition.lifecycleListeners.getAll();
	 	for each (var listener:ObjectLifecycleListener in listeners) {
 			listener.postConstruct(instance, context);
		}		
	}

	/**
	 * Processes the lifecycle listeners for the specified instance before it gets removed from the Context.
	 * 
	 * @param instance the instance to process
	 * @param definition the definition of the specified instance
	 * @param context the Context the instance belongs to
	 */	
	protected function processPreDestroyListeners (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var listeners:Array = definition.lifecycleListeners.getAll();
	 	for each (var listener:ObjectLifecycleListener in listeners) {
 			listener.preDestroy(instance, context);
		}		
	}
	
	/**
	 * Resolves the specified value, resolving any object references or inline object definitions.
	 * 
	 * @param value the value to resolve
	 * @param context the associated Context
	 * @return the resolved value
	 */
	protected function resolveValue (value:*, context:Context) : * {
		if (value is ObjectIdReference) {
			var idRef:ObjectIdReference = ObjectIdReference(value);
			if (!context.containsObject(idRef.id)) {
				if (idRef.required) {
					throw new ContextError("Required object with id " + idRef.id + " does not exist");
				}
				else {
					return null;
				}
			} else {
				return context.getObject(idRef.id);
			}
		}
		else if (value is ObjectTypeReference) {
			var typeRef:ObjectTypeReference = ObjectTypeReference(value);
			if (typeRef.type.isType(Context)) {
				return context;
			}
			var ids:Array = context.getObjectIds(typeRef.type.getClass());
			if (ids.length > 1) {
				throw new ContextError("Ambigous dependency: Context contains more than one object of type "
						+ typeRef.type.name);
			} 
			else if (ids.length == 0) {
				if (typeRef.required) {
					throw new ContextError("Unsatisfied dependency: Context does not contain an object of type " 
						+ typeRef.type.name);
				}
				else {
					return null;
				}				
			}
			else {
				return context.getObject(ids[0]);
			}
		}
		else if (value is ObjectDefinition) {
			var definition:ObjectDefinition = ObjectDefinition(value);
			var instance:Object = createObject(definition, context);
			configureObject(instance, definition, context);
			return instance;
		}
		else if (value is MessageDispatcherFunctionReference) {
			// two lines to avoid compiler warning
			var delegate:MessageDispatcherFunctionReference = MessageDispatcherFunctionReference(value);
			delegate.domain = domain;
			delegate.router = context.messageRouter;
			var r:* = delegate.dispatchMessage;
			return r;
		}
		else if (value is ManagedArray) {
			var source:Array = value as Array;
			var result:Array = new Array();
			for each (var element:* in source) {
				result.push(resolveValue(element, context));			
			}
			return result;
		} 
		else {
			return value;
		}
	}

	/**
	 * Resolves the specified Array, recursively resolving any object references or inline object definitions 
	 * of its elements.
	 * 
	 * @param array the Array to resolve
	 * @param context the associated Context
	 * @return the resolved Array
	 */
	protected function resolveArray (array:Array, context:Context) : Array {
		for (var i:uint = 0; i < array.length; i++) {
			array[i] = resolveValue(array[i], context);
		}
		return array;
	}
	
	
}

}
