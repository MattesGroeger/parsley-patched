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

package org.spicefactory.parsley.core.state.manager.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.state.GlobalViewState;
import org.spicefactory.parsley.core.view.handler.ContextLookupEvent;

import flash.display.DisplayObject;

/**
 * Default implementation of the GlobalViewState interface.
 * 
 * @author Jens Halm
 */
public class DefaultGlobalViewState implements GlobalViewState {
	
	
	/**
	 * @inheritDoc
	 */
	public function findContextInHierarchy (view:DisplayObject, callback:Function, requiredEvent:String = null) : void {
		var f:Function = (requiredEvent) ? function (context:Context) : void {
			waitFor(context, requiredEvent, callback);
		} : callback;
		var event:ContextLookupEvent = new ContextLookupEvent(f);
		view.dispatchEvent(event);
		if (!event.processed) callback(null);
	}
	
	private function waitFor (context:Context, event:String, callback:Function) : void {
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
	
	
}
}
