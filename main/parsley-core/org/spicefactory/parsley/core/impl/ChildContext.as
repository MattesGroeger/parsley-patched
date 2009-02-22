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
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.impl.DefaultContext;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

/**
 * @author Jens Halm
 */
public class ChildContext extends DefaultContext {


	private var _parent:Context;
	private var _destroyCommand:Command;


	public function ChildContext (parent:Context, registry:ObjectDefinitionRegistry = null, 
			factory:ObjectFactory = null) {
		super(registry, parent.messageDispatcher, factory);
		_parent = parent;
		_destroyCommand = new Command(destroy);
		_parent.addDestroyCommand(_destroyCommand); 
		// TODO - would be better if this would be executed before destroyCommands of parent
	}
	

	public function get parent () : Context {
		return _parent;
	}
	
	
	public override function get objectCount () : uint {
		return super.objectCount + _parent.objectCount;
	}
	
	public override function get objectIds () : Array {
		return super.objectIds.concat(_parent.objectIds);
	}
	
	public override function containsObject (id:String) : Boolean {
		return super.containsObject(id) || _parent.containsObject(id);
	}
	
	public override function getType (id:String) : Class {
		return super.containsObject(id) ? super.getType(id) : _parent.getType(id);
	}
	
	public override function getObjectsByType (type:Class) : Array {
		return super.getObjectsByType(type).concat(_parent.getObjectsByType(type));
	}
	
	public override function getObject (id:String) : Object {
		return super.containsObject(id) ? super.getObject(id) : _parent.getObject(id);
	}
	
	
	public override function destroy () : void {
		_parent.removeDestroyCommand(_destroyCommand);
		super.destroy();
	}	
	
	
}

}
