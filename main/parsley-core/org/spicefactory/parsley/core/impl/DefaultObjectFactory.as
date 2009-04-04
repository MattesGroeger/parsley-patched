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

package org.spicefactory.parsley.core.impl {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;
import org.spicefactory.parsley.factory.model.ObjectIdReference;
import org.spicefactory.parsley.factory.model.ObjectTypeReference;
import org.spicefactory.parsley.factory.model.PropertyValue;
import org.spicefactory.parsley.factory.registry.MethodParameterRegistry;
import org.spicefactory.parsley.messaging.impl.MessageDispatcherFunctionReference;

/**
 * @author Jens Halm
 */
public class DefaultObjectFactory implements ObjectFactory {


	public function createObject (definition:ObjectDefinition, context:Context) : Object {
		if (definition.instantiator != null) {
			return definition.instantiator.instantiate(context);
		}
		else {
			var args:Array = resolveArray(definition.constructorArgs.getAll(), context);
			return definition.type.newInstance(args);
		}
	}
	
	public function configureObject (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	processProperties(instance, definition, context);
	 	processMethods(instance, definition, context);
	 	processLifecycleListeners(instance, definition, context);
	}
	
	protected function processProperties (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var props:Array = definition.properties.getAll();
	 	for each (var prop:PropertyValue in props) {
	 		var value:* = resolveValue(prop.value, context);
	 		prop.property.setValue(instance, value);
		}		
	}
	
	protected function processMethods (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var methods:Array = definition.injectorMethods.getAll();
	 	for each (var mpr:MethodParameterRegistry in methods) {
			var params:Array = resolveArray(mpr.getAll(), context);
	 		mpr.method.invoke(instance, params);
		}		
	}
	
	protected function processLifecycleListeners (instance:Object, definition:ObjectDefinition, context:Context) : void {
	 	var listeners:Array = definition.lifecycleListeners.getAll();
	 	for each (var listener:ObjectLifecycleListener in listeners) {
 			listener.postConstruct(instance, context);
		}		
	}
	
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
			// TODO - context.getIdsForType would be better
			var objects:Array = context.getObjectsByType(typeRef.type.getClass());
			if (objects.length > 1) {
				throw new ContextError("Ambigous dependency: Context contains more than one object of type "
						+ typeRef.type.name);
			} 
			else if (objects.length == 0) {
				if (typeRef.required) {
					throw new ContextError("Unsatisfied dependency: Context does not contain an object of type " 
						+ typeRef.type.name);
				}
				else {
					return null;
				}				
			}
			else {
				return objects[0];
			}
		}
		else if (value is MessageDispatcherFunctionReference) {
			// two lines to avoid compiler warning
			var r:* = context.messageRouter.dispatchMessage;
			return r;
		}
		else {
			// TODO - handle ManagedArray
			return value;
		}
	}

	protected function resolveArray (array:Array, context:Context) : Array {
		for (var i:uint = 0; i < array.length; i++) {
			array[i] = resolveValue(array[i], context);
		}
		return array;
	}
	
	
}

}
