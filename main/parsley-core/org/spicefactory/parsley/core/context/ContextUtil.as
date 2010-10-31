/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.core.context {
import org.spicefactory.parsley.core.factory.impl.DefaultContextStrategyProvider;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.lifecycle.impl.ManagedObjectLookup;
import org.spicefactory.parsley.core.scope.ScopeRegistry;
import org.spicefactory.parsley.core.view.handler.ContextLookupEvent;

import flash.display.DisplayObject;

/**
 * Utility methods that allow to query the state of views or managed instances globally.
 * 
 * @author Jens Halm
 */
public class ContextUtil {
	
	
	/**
	 * Indicates whether the specified instance is currently managed by any Context.
	 * 
	 * @param instance the instance to check the state for
	 * @return true if the specified instance is currently managed by any Context
	 */
	public static function isManaged (instance:Object) : Boolean {
		return (ManagedObjectLookup.forInstance(instance) != null);
	}

	/**
	 * Returns the Context that manages the specified instance or null if the
	 * object is not managed by any Context currently.
	 * 
	 * @param instance the object to return the corresponding Context for
	 * @return the Context manages the specified instance
	 */
	public static function getContext (instance:Object) : Context {
		var mo:ManagedObject = ManagedObjectLookup.forInstance(instance);
		return (mo) ? mo.context : null;
	}

	/**
	 * Finds the nearest Context in the view hierarchy above the specified DisplayObject.
	 * This is an asynchronous operation, hence a callback must be specified with one parameter
	 * of type Context. It may be invoked with a null value in case no Context is found in the view
	 * hierarchy. The third parameter allows to specify an Event (any of the constants of <code>ContextEvent</code>).
	 * If specified the callback will not be invoked before that event has fired. If omitted the callback will
	 * be invoked as soon as the Context is found.
	 * 
	 * @param view the view to use as a starting point for the Context lookup
	 * @param callback the callback to invoke as soon as the Context is found and in the required state
	 * @param requiredEvent the event that needs to have been fired before the callback gets invoked
	 */
	public static function findContextInView (view:DisplayObject, callback:Function, requiredEvent:String = null) : void {
		var f:Function = (requiredEvent) ? function (context:Context) : void {
			waitFor(context, requiredEvent, callback);
		} : callback;
		var event:ContextLookupEvent = new ContextLookupEvent(f);
		view.dispatchEvent(event);
		if (!event.processed) callback(null);
	}
	
	private static function waitFor (context:Context, event:String, callback:Function) : void {
		if (event == ContextEvent.INITIALIZED) {
			if (context.initialized) {
				callback(context);
				return;
			}
		}
		else if (event == ContextEvent.CONFIGURED) {
			if (context.configured) {
				callback(context);
				return;
			}
		}
		else if (event == ContextEvent.DESTROYED) {
			if (context.destroyed) {
				callback(context);
				return;
			}
		}
		else {
			throw new IllegalStateError("Illegal Context event type: " + event);
		}
		var f:Function = function (event:ContextEvent) : void {
			context.removeEventListener(event.type, f);
			callback(context);
		};
		context.addEventListener(event, f);	
	}
	
	/**
	 * The global registry for all registered scopes.
	 */
	public static function get globalScopeRegistry () : ScopeRegistry {
		return DefaultContextStrategyProvider.scopeRegistry;
	}


}
}
