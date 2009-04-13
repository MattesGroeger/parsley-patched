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

package org.spicefactory.parsley.core.impl {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.impl.DefaultContext;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

/**
 * @author Jens Halm
 */
public class ChildContext extends DefaultContext {


	private var _parent:Context;


	public function ChildContext (parent:Context, registry:ObjectDefinitionRegistry = null, 
			factory:ObjectFactory = null) {
		super(registry, parent.messageRouter, factory);
		_parent = parent;
		_parent.addEventListener(ContextEvent.DESTROYED, parentDestroyed, false, 1); // want to process before parent
	}
	

	public function get parent () : Context {
		return _parent;
	}
	
	
	public override function initialize () : Boolean {
		return super.initialize() && _parent.initialized;
	}
	
	public override function get initialized () : Boolean {
		return super.initialized && _parent.initialized;
	}
	
	
	public override function getObjectCount (type:Class = null) : uint {
		return super.getObjectCount(type) + _parent.getObjectCount(type);
	}
	
	public override function getObjectIds (type:Class = null) : Array {
		return super.getObjectIds(type).concat(_parent.getObjectIds(type));
	}
	
	public override function containsObject (id:String) : Boolean {
		return super.containsObject(id) || _parent.containsObject(id);
	}
	
	public override function getObject (id:String) : Object {
		return super.containsObject(id) ? super.getObject(id) : _parent.getObject(id);
	}

	public override function getType (id:String) : Class {
		return super.containsObject(id) ? super.getType(id) : _parent.getType(id);
	}
	
	public override function getAllObjectsByType (type:Class) : Array {
		return super.getAllObjectsByType(type).concat(_parent.getAllObjectsByType(type));
	}
	
	public override function getObjectByType (type:Class, required:Boolean = false) : Object {
		var local:Object = super.getObjectByType(type);
		return (local == null) ? _parent.getObjectByType(type, required) : local; 
	}
	
	
	
	private function parentDestroyed (event:ContextEvent) : void {
		destroy();
	}
	
	
}

}
