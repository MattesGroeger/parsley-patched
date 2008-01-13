/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.mvc.impl {
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.mvc.Action;
import org.spicefactory.parsley.mvc.ApplicationEvent;

/**
 * An <code>ActionRegistration</code> implementation that serves as 
 * a registration for a lazily initialized <code>Action</code> delegate configured in an
 * <code>ApplicationContext</code>.
 * 
 * @author Jens Halm
 */
public class ApplicationContextAction implements ActionRegistration {
	
	
	
	private var _delegate:Function;
	
	private var context:ApplicationContext;
	private var objectId:String;
	private var methodName:String;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the context containing the action
	 * @param objectId the id of the action in the context
	 * @param methodName the (optional) name of the action method if the object does not implement the
	 * Action interface
	 */
	function ApplicationContextAction (context:ApplicationContext, 
			objectId:String, methodName:String = null) {
		this.context = context;
		this.objectId = objectId;
		this.methodName = methodName;		
	}
	
	
	private function get delegate () : Function {
		if (_delegate == null) {
			_delegate = createDelegate();
		}
		return _delegate;
	}
	
	private function createDelegate () : Function {
		var target:Object = context.getObject(objectId);
		if (target == null) {
			throw new ConfigurationError("No object registered with id " + objectId);
		}
		if (methodName == null) {
			if (!(target is Action)) {
				throw new ConfigurationError("No method name specified and target does not implement Action");
			}
			return Action(target).execute;
		} else {
			if (!(target[methodName] is Function)) {
				throw new ConfigurationError("No method with name " + methodName 
					+ " in object with id " + objectId);
			}
			return target[methodName] as Function;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function execute (event:ApplicationEvent) : void {
		var f:Function = delegate;
		f(event);
	}
	
	/**
	 * @inheritDoc
	 */
	public function equals (other : ActionRegistration) : Boolean {
		if (!(other is ApplicationContext)) {
			return false;
		}
		var otherAction : ApplicationContextAction = ApplicationContextAction(other);
		return (context == otherAction.context 
			&& objectId == otherAction.objectId 
			&& methodName == otherAction.methodName);
	}
	
}

}
