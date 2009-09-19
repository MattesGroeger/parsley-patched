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

package org.spicefactory.parsley.core.scopes.impl {
import org.spicefactory.parsley.core.scopes.ObjectLifecycleScope;
import org.spicefactory.parsley.core.messaging.MessageRouter;

/**
 * @author Jens Halm
 */
public class DefaultScope implements InternalScope {


	private var definition:ScopeDefinition;
	private var _messageRouter:MessageRouter;
	private var _lifecycleEventRouter:MessageRouter;
	private var _objectLifecycle:ObjectLifecycleScope;
	
	
	function DefaultScope (definition:ScopeDefinition, messageRouter:MessageRouter, lifecycleEventRouter:MessageRouter) {
		this.definition = definition;
		this._messageRouter = messageRouter;
		this._lifecycleEventRouter = lifecycleEventRouter;
		this._objectLifecycle = new DefaultObjectLifecycleScope(lifecycleEventRouter);
	}

	
	public function get name () : String {
		return definition.name;
	}
	
	public function get inherited () : Boolean {
		return definition.inherited;
	}
	
	public function get messageRouter () : MessageRouter {
		return _messageRouter;
	}
	
	public function get objectLifecycle () : ObjectLifecycleScope {
		return _objectLifecycle;
	}
	
	public function get lifecycleEventRouter () : MessageRouter {
		return _lifecycleEventRouter;
	}
	
	
}
}
