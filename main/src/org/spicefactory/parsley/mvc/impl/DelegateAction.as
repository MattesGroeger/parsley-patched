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
import org.spicefactory.parsley.mvc.ApplicationEvent;

/**
 * An <code>ActionRegistration</code> implementation that serves as 
 * a registration for a simple function delegate.
 * 
 * @author Jens Halm
 */
public class DelegateAction implements ActionRegistration {
	
	
	private var delegate:Function;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param delegate the action delegate
	 */
	function DelegateAction (delegate:Function) {
		this.delegate = delegate;
	}

	
	/**
	 * @inheritDoc
	 */
	public function execute (event:ApplicationEvent) : void {
		delegate(event);
	}
	
	/**
	 * @inheritDoc
	 */
	public function equals (other : ActionRegistration) : Boolean {
		if (!(other is DelegateAction)) {
			return false;
		}
		var otherAction : DelegateAction = DelegateAction(other);
		return (delegate == otherAction.delegate);
	}
	
	
}

}
