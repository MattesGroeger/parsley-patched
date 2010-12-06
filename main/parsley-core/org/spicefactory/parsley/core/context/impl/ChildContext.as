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
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.registry.ObjectDefinition;

/**
 * Implementation of the <code>Context</code> interface that is capable of handling a parent <code>Context</code>.
 * 
 * @author Jens Halm
 */
public class ChildContext extends DefaultContext {


	private var _parent:Context;


	public override function init (info:BootstrapInfo) : void {
		super.init(info);
		_parent = info.parent;
		if (_parent) {
			_parent.addEventListener(ContextEvent.DESTROYED, parentDestroyed, false, 2); // want to process before parent
			addEventListener(ContextEvent.DESTROYED, childDestroyed, false);
		}
	}
	
	
	/**
	 * @private
	 */
	protected override function initializeSingletons () : void {
		if (!parent || parent.initialized) { 
			super.initializeSingletons();
		}
		else {
			/* Here we want to wait until all singletons in the parent have been initialized in the
			 * order that was configured for the parent, without interfering through instantiating
			 * objects in this Context which might need dependencies from the parent. */
			parent.addEventListener(ContextEvent.INITIALIZED, parentInitialized);
		}
	}
	
	private function parentInitialized (event:ContextEvent) : void {
		parent.removeEventListener(ContextEvent.INITIALIZED, parentInitialized);
		super.initializeSingletons();
	}

	/**
	 * The parent Context of this Context.
	 */
	public function get parent () : Context {
		return _parent;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public override function get configured () : Boolean {
		return (_parent) ? super.configured && _parent.configured : super.configured;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function get initialized () : Boolean {
		return (_parent) ? super.initialized && _parent.initialized : super.initialized;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public override function getObjectCount (type:Class = null) : uint {
		return  (_parent) ? super.getObjectCount(type) + _parent.getObjectCount(type) : super.getObjectCount(type);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getObjectIds (type:Class = null) : Array {
		return (_parent) ? super.getObjectIds(type).concat(_parent.getObjectIds(type)) : super.getObjectIds(type);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function containsObject (id:String) : Boolean {
		return super.containsObject(id) || (_parent && _parent.containsObject(id));
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getObject (id:String) : Object {
		return (!_parent || super.containsObject(id)) ? super.getObject(id) : _parent.getObject(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getType (id:String) : Class {
		return (!_parent || super.containsObject(id)) ? super.getType(id) : _parent.getType(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function isDynamic (id:String) : Boolean {
		return (!_parent || super.containsObject(id)) ? super.isDynamic(id) : _parent.isDynamic(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getAllObjectsByType (type:Class) : Array {
		return (_parent)
				? super.getAllObjectsByType(type).concat(_parent.getAllObjectsByType(type))
				: super.getAllObjectsByType(type);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getObjectByType (type:Class) : Object {
		var localCount:int = super.getObjectCount(type);
		return (localCount == 0 && _parent) ? _parent.getObjectByType(type) : super.getObjectByType(type); 
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getDefinition (id:String) : ObjectDefinition {
		return (!_parent || super.containsObject(id)) ? super.getDefinition(id) : _parent.getDefinition(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function getDefinitionByType (type:Class) : ObjectDefinition {
		var localCount:int = super.getObjectCount(type);
		return (localCount == 0 && _parent) ? _parent.getDefinitionByType(type) : super.getDefinitionByType(type); 
	}
	
	/**
	 * @inheritDoc
	 */
	public override function createDynamicObject (id:String) : DynamicObject {
		return (!_parent || super.containsObject(id)) ? super.createDynamicObject(id) : _parent.createDynamicObject(id);
	}
	
	/**
	 * @inheritDoc
	 */
	public override function createDynamicObjectByType (type:Class) : DynamicObject {
		var localCount:int = super.getObjectCount(type);
		return (localCount == 0 && _parent) ? _parent.createDynamicObjectByType(type) : super.createDynamicObjectByType(type); 
	}
	
	private function childDestroyed (event:ContextEvent) : void {
		removeEventListener(ContextEvent.DESTROYED, childDestroyed);
		_parent.removeEventListener(ContextEvent.DESTROYED, parentDestroyed);
	}
	
	private function parentDestroyed (event:ContextEvent) : void {
		destroy();
	}
	
	
}

}
