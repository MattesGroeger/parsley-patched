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
import org.spicefactory.parsley.mvc.Action;
import org.spicefactory.parsley.mvc.ApplicationEvent;

/**
 * An <code>ActionRegistration</code> implementation that simply wraps an <code>Action</code> instance.
 * 
 * @author Jens Halm
 */
public class WrappedAction implements ActionRegistration {


	private var action:Action;


	/**
	 * Creates a new instance.
	 * 
	 * @param action the action to wrap
	 */
	function WrappedAction (action:Action) {
		this.action = action;
	}
	
	/**
	 * @inheritDoc
	 */
	public function execute (event:ApplicationEvent) : void {
		action.execute(event);
	}
	
	/**
	 * @inheritDoc
	 */
	public function equals (other : ActionRegistration) : Boolean {
		if (!(other is WrappedAction)) {
			return false;
		}
		var otherAction : WrappedAction = WrappedAction(other);
		return (action == otherAction.action);
	}
	
	
}

}
