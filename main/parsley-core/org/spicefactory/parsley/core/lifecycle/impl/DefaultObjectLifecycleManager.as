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
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.InitializingService;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.lifecycle.ManagedObjectHandler;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.scope.impl.ScopeInfo;

import flash.system.ApplicationDomain;

/**
 * Default implementation of the ObjectLifecycleManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectLifecycleManager implements ObjectLifecycleManager, InitializingService {
	
	
	private var handlers:Array = new Array();
	private var destroyed:Boolean;

	private var domain:ApplicationDomain;
	private var scopes:Array;


	/**
	 * Creates a new instance.
	 */
	function DefaultObjectLifecycleManager () {
		
	}

	/**
	 * @inheritDoc
	 */
	public function init (info:BootstrapInfo) : void {
		this.domain = info.domain;
		this.scopes = info.scopes;
	}

	/**
	 * @inheritDoc
	 */
	public function createHandler (definition:ObjectDefinition, context:Context) : ManagedObjectHandler {
		var handler:ManagedObjectHandler = new DefaultManagedObjectHandler(definition, context, this);
		handlers.push(handler);
		return handler;
	}

	/**
	 * @private
	 */	
	internal function processObservers (instance:Object, event:ObjectLifecycle, id:String = null) : void {
		for each (var scope:ScopeInfo in scopes) {
			scope.lifecycleEventRouter.dispatchMessage(instance, domain, event.key);
			if (id != null) {
				scope.lifecycleEventRouter.dispatchMessage(instance, domain, event.key + ":" + id);				
			}
		}
	}
	
	/**
	 * @private
	 */	
	internal function removeHandler (handler:ManagedObjectHandler) : void {
		if (destroyed) return;
		ArrayUtil.remove(handlers, handler);
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroyAll () : void {
		destroyed = true;
		try {
			for each (var handler:ManagedObjectHandler in handlers) {
				handler.destroyObject();
			}
		}
		finally {
			handlers = new Array();
		}
	}
	
	
}

}