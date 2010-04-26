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
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectProcessor;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
import org.spicefactory.parsley.core.registry.definition.MethodParameterRegistry;
import org.spicefactory.parsley.core.registry.model.ManagedArray;
import org.spicefactory.parsley.core.registry.model.ObjectIdReference;
import org.spicefactory.parsley.core.registry.model.ObjectTypeReference;
import org.spicefactory.parsley.core.registry.model.PropertyValue;
import org.spicefactory.parsley.core.scope.impl.ScopeDefinition;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the ObjectLifecycleManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectLifecycleManager implements ObjectLifecycleManager {
	
	
	// maps ManagedObject -> Boolean
	private var rootInstances:Dictionary = new Dictionary();
	// maps ManagedObject -> Boolean
	private var dependentInstances:Dictionary = new Dictionary();

	// maps parent ManagedObject -> child ManagedObject
	private var parentChildMap:Dictionary = new Dictionary();
	
	// maps ManagedObject -> processors
	private var processorMap:Dictionary = new Dictionary();

	private var domain:ApplicationDomain;
	private var scopes:Array;


	/**
	 * Creates a new instance.
	 * 
	 * @param domain the ApplicationDomain to use for reflection
	 * @param scopes the ScopeDefinitions for dispatching lifecycle events
	 */
	function DefaultObjectLifecycleManager (domain:ApplicationDomain, scopes:Array) {
		this.domain = domain;
		this.scopes = scopes;		
	}


	/**
	 * @inheritDoc
	 */
	public function createObject (definition:ObjectDefinition, context:Context) : ManagedObject {
		var object:ManagedObjectImpl = new ManagedObjectImpl(definition, context);
		if (definition.instantiator != null) {
			 object.instance = definition.instantiator.instantiate(context);
		}
		else {
			/* deprecated */
			var args:Array = resolveArray(definition.constructorArgs.getAll(), object);
			object.instance = definition.type.newInstance(args);
		}
		return object;
	}
	
	/**
	 * @inheritDoc
	 */
	public function configureObject (object:ManagedObject) : void {
		doConfigure(object);
		rootInstances[object] = true;
	}

	private function doConfigure (object:ManagedObject) : void {
	 	createProcessors(object);

		processLifecycle(object, ObjectLifecycle.PRE_CONFIGURE);
		
		/* deprecated */
		processProperties(object);
		/* deprecated */
	 	processMethods(object);
	 	
	 	invokePreInitMethods(object);
		processLifecycle(object, ObjectLifecycle.PRE_INIT);
		if (object.definition.initMethod != null) {
			object.definition.type.getMethod(object.definition.initMethod).invoke(object.instance, []);
		}
		processLifecycle(object, ObjectLifecycle.POST_INIT);
	}
	
	private function mapChild (parent:ManagedObject, child:ManagedObject) : void {
		dependentInstances[child] = true;
		var children:Array = parentChildMap[parent];
		if (children == null) {
			children = new Array();
			parentChildMap[parent] = children;
		}
		children.push(child);
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroyObject (object:ManagedObject) : void {
		if (dependentInstances[object] != undefined) {
			throw new IllegalArgumentError("Instance that depends on the lifecycle of a parent object cannot be removed: "
					+ object.instance);
		}
		doDestroy(object);
		delete rootInstances[object];
		delete processorMap[object];
		var children:Array = parentChildMap[object];
		if (children != null) {
			for each (var child:ManagedObject in children) {
				doDestroy(child);
				delete dependentInstances[child];
				delete processorMap[child];
			}
			delete parentChildMap[object];
		}
	}

	/**
	 * @inheritDoc
	 */
	public function destroyAll () : void {
		for (var object:Object in rootInstances) {
			doDestroy(ManagedObject(object));
		}
		for (var child:Object in dependentInstances) {
			doDestroy(ManagedObject(child));
		}
		rootInstances = new Dictionary();
		dependentInstances = new Dictionary();
		parentChildMap = new Dictionary();
		processorMap = new Dictionary();
	}
	
	private function doDestroy (object:ManagedObject) : void {
		processLifecycle(object, ObjectLifecycle.PRE_DESTROY);
		if (object.definition.destroyMethod != null) {
			object.definition.type.getMethod(object.definition.destroyMethod).invoke(object.instance, []);
		}
	 	invokePostDestroyMethods(object);
		processLifecycle(object, ObjectLifecycle.POST_DESTROY);
	}
	
	/**
	 * Invokes the preInit methods on all processor for the specified target instance.
	 * 
	 * @param object the target object to invoke the processors for
	 */
	protected function invokePreInitMethods (object:ManagedObject) : void {
		var processors:Array = processorMap[object];
		for each (var processor:ObjectProcessor in processors) {
			processor.preInit();
		}
	}
	
	/**
	 * Invokes the postDestroy methods on all processor for the specified target instance.
	 * 
	 * @param object the target object to invoke the processors for
	 */
	protected function invokePostDestroyMethods (object:ManagedObject) : void {
		var processors:Array = processorMap[object];
		for each (var processor:ObjectProcessor in processors) {
			processor.postDestroy();
		}
	}
	
	/**
	 * Processes all processor factories of the specified definition and creates new processors for 
	 * the target instance.
	 * 
	 * @param object the object to process
	 */
	protected function createProcessors (object:ManagedObject) : void {
		var processors:Array = new Array();
		for each (var factory:ObjectProcessorFactory in object.definition.processorFactories) {
			processors.push(factory.createInstance(object));
		}
		processorMap[object] = processors;
	}
	
	/**
	 * Deprecated
	 */
	private function processProperties (object:ManagedObject) : void {
	 	var props:Array = object.definition.properties.getAll();
	 	for each (var prop:PropertyValue in props) {
	 		var value:* = resolveValue(prop.value, object, true, prop.property.type.isType(Array));
	 		if (!(value is UnsatisfiedDependency)) {
	 			prop.property.setValue(object.instance, value);
	 		}
		}		
	}

	/**
	 * Deprecated
	 */
	private function processMethods (object:ManagedObject) : void {
	 	var methods:Array = object.definition.injectorMethods.getAll();
	 	for each (var mpr:MethodParameterRegistry in methods) {
			var params:Array = resolveArray(mpr.getAll(), object);
	 		mpr.method.invoke(object.instance, params);
		}		
	}
	
	/**
	 * Processes the lifecycle listeners for the specified instance.
	 * 
	 * @param object the object to process
	 * @param event the lifecycle event type
	 */
	protected function processLifecycle (object:ManagedObject, event:ObjectLifecycle) : void {
		
		/* deprecated */
	 	var listeners:Array = object.definition.objectLifecycle.getListeners(event);
		for each (var listener:Function in listeners) {
 			listener(object.instance, object.context);
		}	
		
		var id:String = object.definition.id;
		for each (var scope:ScopeDefinition in scopes) {
			scope.lifecycleEventRouter.dispatchMessage(object.instance, domain, event.key);
			if (id != null) {
				scope.lifecycleEventRouter.dispatchMessage(object.instance, domain, event.key + ":" + id);				
			}
		}
	}

	
	/**
	 * Resolves the specified value, resolving any object references or inline object definitions.
	 * 
	 * @param value the value to resolve
	 * @param parent the object the value belongs to
	 * @param designateUnsatisfiedDependencies if true returns an instance of UnsatisfiedDependency instead of null
	 * @param arrayTargetType whether to resolve type reference for an Array target type
	 * @return the resolved value
	 */
	protected function resolveValue (value:*, parent:ManagedObject, 
			designateUnsatisfiedDependencies:Boolean = false, arrayTargetType:Boolean = false) : * {
		if (value is ObjectIdReference) {
			var idRef:ObjectIdReference = ObjectIdReference(value);
			if (!parent.context.containsObject(idRef.id)) {
				if (idRef.required) {
					throw new ContextError("Required object with id " + idRef.id + " does not exist");
				}
				else {
					return (designateUnsatisfiedDependencies) ? UnsatisfiedDependency.INSTANCE : null;
				}
			} else {
				return parent.context.getObject(idRef.id);
			}
		}
		else if (value is ObjectTypeReference) {
			var typeRef:ObjectTypeReference = ObjectTypeReference(value);
			if (typeRef.type.isType(Context)) {
				return parent.context;
			}
			if (arrayTargetType) {
				return parent.context.getAllObjectsByType(typeRef.type.getClass());
			}
			var ids:Array = parent.context.getObjectIds(typeRef.type.getClass());
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
					return (designateUnsatisfiedDependencies) ? UnsatisfiedDependency.INSTANCE : null;
				}				
			}
			else {
				return parent.context.getObject(ids[0]);
			}
		}
		else if (value is ObjectDefinition) {
			var definition:ObjectDefinition = ObjectDefinition(value);
			var child:ManagedObject = createObject(definition, parent.context);
			doConfigure(child);
			mapChild(parent, child);
			return child.instance;
		}
		else if (value is ManagedArray) {
			var source:Array = value as Array;
			var result:Array = new Array();
			for each (var element:* in source) {
				result.push(resolveValue(element, parent));			
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
	 * @param parent the object the value belongs to
	 * @return the resolved Array
	 */
	protected function resolveArray (array:Array, parent:ManagedObject) : Array {
		for (var i:uint = 0; i < array.length; i++) {
			array[i] = resolveValue(array[i], parent);
		}
		return array;
	}
	
	
}
}

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectDefinition;

class ManagedObjectImpl implements ManagedObject {
	
	private var _instance:Object;
	private var _definition:ObjectDefinition;
	private var _context:Context;
	
	function ManagedObjectImpl (definition:ObjectDefinition, context:Context) {
		_definition = definition;
		_context = context;
	}
	
	public function get instance () : Object {
		return _instance;
	}
	
	public function get definition () : ObjectDefinition {
		return _definition;
	}
	
	public function get context () : Context {
		return _context;
	}
	
	public function set instance (value:Object) : void {
		_instance = value;
	}
	
}

