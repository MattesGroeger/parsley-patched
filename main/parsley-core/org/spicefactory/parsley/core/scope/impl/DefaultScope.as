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

package org.spicefactory.parsley.core.scope.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.Delegate;
import org.spicefactory.lib.util.DelegateChain;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.lifecycle.LifecycleObserverRegistry;
import org.spicefactory.parsley.core.lifecycle.impl.DefaultLifecycleObserverRegistry;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessage;
import org.spicefactory.parsley.core.scope.ObjectLifecycleScope;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeExtensions;

import flash.system.ApplicationDomain;

/**
 * Default implementation of the Scope interface.
 * 
 * @author Jens Halm
 */
public class DefaultScope implements Scope {

	private var context:Context;
	private var deferredActions:DelegateChain;
	private var activated:Boolean = false;	
	
	private var domain:ApplicationDomain;
	private var scopeDef:ScopeInfo;
	private var _objectLifecycle:ObjectLifecycleScope;
	private var _lifecycleObservers:LifecycleObserverRegistry;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the Context this scope instance is associated with
	 * @param scopeDef the shared definition for this scope
	 * @param domain the ApplicationDomain to use for reflection
	 */
	function DefaultScope (context:Context, scopeDef:ScopeInfo, domain:ApplicationDomain) {
		this.context = context;
		this.scopeDef = scopeDef;
		this.domain = domain;
		this._objectLifecycle = new DefaultObjectLifecycleScope(scopeDef.lifecycleEventRouter.receivers);
		this._lifecycleObservers = new DefaultLifecycleObserverRegistry(scopeDef.lifecycleEventRouter.receivers);
		
		if (context.configured) {
			activated = true;
		}
		else {
			deferredActions = new DelegateChain();
			context.addEventListener(ContextEvent.CONFIGURED, contextConfigured);
			context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		}
	}

	private function contextConfigured (event:ContextEvent) : void {
		removeListeners();
		activated = true;
		deferredActions.invoke();
		deferredActions = null;
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		removeListeners();
	}
	
	private function removeListeners () : void {
		context.removeEventListener(ContextEvent.CONFIGURED, contextConfigured);
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	/**
	 * @private
	 */
	internal function broadcastMessage (message:Object, selector:*, scopes:Array) : void {
		if (!activated) {
			deferredActions.addDelegate(new Delegate(doBroadcastMessage, [message, selector, scopes]));
		}
		else {
			doBroadcastMessage(message, selector, scopes);
		}
	}
	
	/**
	 * @private
	 */
	internal function observeCommand (command:Command, scopes:Array) : void {
		if (!activated) {
			deferredActions.addDelegate(new Delegate(doObserveCommand, [command, scopes]));
		}
		else {
			doObserveCommand(command, scopes);
		}
	}
	
	private function doBroadcastMessage (message:Object, selector:*, scopes:Array) : void {
		var type:ClassInfo = ClassInfo.forInstance(message, domain);
		var msg:Message = new DefaultMessage(message, type, selector, context);
		var caches:Array;
		if (scopes) {
			caches = new Array();
			for each (var scope:DefaultScope in scopes) {
				caches.push(scope.scopeDef.messageRouter.getReceiverCache(type));
			}
		}
		scopeDef.messageRouter.dispatchMessage(msg, caches);
	}
	
	private function doObserveCommand (command:Command, scopes:Array) : void {
		var caches:Array = new Array();
		for each (var scope:DefaultScope in scopes) {
			var router:MessageRouter = scope.scopeDef.messageRouter;
			caches.push(router.getReceiverCache(command.message.type));
			router.observeCommand(command);
		}
		scopeDef.messageRouter.observeCommand(command, caches);
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, selector:* = undefined) : void {
		broadcastMessage(message, selector, null);
	}	
	
	/**
	 * @inheritDoc
	 */
	public function get name () : String {
		return scopeDef.name;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get uuid () : String {
		return scopeDef.uuid;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get inherited () : Boolean {
		return scopeDef.inherited;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get rootContext () : Context {
		return scopeDef.rootContext;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get messageReceivers () : MessageReceiverRegistry {
		return scopeDef.messageRouter.receivers;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get commandManager () : CommandManager {
		return scopeDef.messageRouter.commandManager;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get lifecyleObservers () : LifecycleObserverRegistry {
		return _lifecycleObservers;
	}

	[Deprecated(replacement="lifecycleObservers")]
	public function get objectLifecycle () : ObjectLifecycleScope {
		return _objectLifecycle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get extensions () : ScopeExtensions {
		return scopeDef.extensions;
	}

	
}
}

class DeferredMessage {
	internal var message:Object;
	internal var selector:*;
	function DeferredMessage (message:Object, selector:*) {
		this.message = message;
		this.selector = selector;
	}
}

