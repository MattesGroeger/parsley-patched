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

package org.spicefactory.parsley.core.messaging {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.state.manager.GlobalDomainManager;

/**
 * The central message routing facility. Each Scope will contain two MessageRouters internally,
 * one for routing regular messages and one for routing scope-wide object lifecycle events.
 * 
 * @author Jens Halm
 */
public interface MessageRouter {
	
	/**
	 * Initializes this router. Invoked once after the router has been instantiated.
	 * 
	 * @param settings the settings for the router created by this factory
	 * @param domainManager the manager that keeps track of all ApplicationDomains currently used by one or more Context
	 * @param isLifecycleEventRouter whether this router handles object lifecycle events or regular application events
	 */
	function init (settings:MessageSettings, domainManager:GlobalDomainManager, isLifecylceEventRouter:Boolean) : void;
	
	/**
	 * The registry for all receivers of messages dispatched through this router.
	 */
	function get receivers () : MessageReceiverRegistry;
	
	/**
	 * The manager responsible for providing access to all active command executions.
	 */
	function get commandManager () : CommandManager;
	
	/**
	 * Returns the cache of receivers for the specified message type.
	 * If no cache for that type exists yet, implementations should create and return a new
	 * cache instance.
	 * 
	 * @param type the type for return the receiver cache for
	 * @return the cache of receivers for the specified message type
	 */
	function getReceiverCache (type:ClassInfo) : MessageReceiverCache;
	
	/**
	 * Dispatches the specified message, processing all interceptors, handlers and bindings that have
	 * registered for that message type.
	 * 
	 * @param message the message to dispatch
	 * @param receiverCaches additional caches from other scopes to join to the registered receivers of this router
	 */	
	function dispatchMessage (message:Message, receiverCaches:Array = null) : void;
	
	/**
	 * Observes the specified command and dispatches messages to registered observers
	 * when the state of the command changes. When the specified Array of cached observers
	 * is null, implementations should only register the command with the <code>CommandManager</code>
	 * of this instance and not process observers.
	 * 
	 * @param command the command to observe
	 * @param observerCaches additional caches from other scopes to join to the registered observers of this router
	 */
	function observeCommand (command:Command, observerCaches:Array = null) : void;
	
	
}
}
