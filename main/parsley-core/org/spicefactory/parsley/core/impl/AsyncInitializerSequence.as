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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.RootObjectDefinition;
import org.spicefactory.parsley.factory.model.AsyncInitConfig;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class AsyncInitializerSequence {
	
	
	private static const log:Logger = LogContext.getLogger(AsyncInitializerSequence);
	

	private var queuedInits:Array = new Array();
	private var activeDefinition:RootObjectDefinition;
	private var activeInstance:IEventDispatcher;
	private var parallelInits:Dictionary = new Dictionary();
	private var parallelInitCount:int = 0;
	
	private var context:DefaultContext;
	
	
	function AsyncInitializerSequence (context:DefaultContext) {
		this.context = context;
	}

	
	public function addDefinition (def:ObjectDefinition) : void {
		queuedInits.push(def);
	}
	
	
	public function start () : void {
		var sortFunc:Function = function (def1:ObjectDefinition, def2:ObjectDefinition) : int {
			return def1.asyncInitConfig.order - def2.asyncInitConfig.order;
		};
		queuedInits.sort(sortFunc);
		createNextInstance();
	}
	
	public function cancel () : void {
		if (activeInstance != null) {
			removeListeners(activeInstance, activeInstanceComplete, activeInstanceError);
			activeInstance = null;
			activeDefinition = null;
		}
		for (var instance:Object in parallelInits) {
			removeListeners(instance as IEventDispatcher, parallelInstanceComplete, parallelInstanceError);
		}
		parallelInits = new Dictionary();
		parallelInitCount = 0;
	}

	public function get complete () : Boolean {
		return queuedInits.length == 0 && parallelInitCount == 0;
	}
	
	private function createNextInstance () : void {
		trace(" 1");
		if (complete) {
			trace(" 2");
			context.finishInitialization();
			trace(" 3");
			return;
		}
		activeDefinition = queuedInits.shift() as RootObjectDefinition;
		try {
			context.getInstance(activeDefinition);
		}
		catch (e:Error) {
			context.destroyWithError("Initialization of " + activeDefinition + " failed", e);
		}
	}

	public function addInstance (def:ObjectDefinition, instance:Object) : void {
		var asyncObj:IEventDispatcher = IEventDispatcher(instance);
		if (def == activeDefinition) {
			asyncObj.addEventListener(def.asyncInitConfig.completeEvent, activeInstanceComplete);
			asyncObj.addEventListener(def.asyncInitConfig.errorEvent, activeInstanceError);
			activeInstance = asyncObj;
		} 
		else {
			/*
			 * Must be an initialization that was not triggered by this class.
			 * Instead it was either tiggered by application code accessing the Context before the
			 * INITIALIZED event or by a dependency of an object that this class initialized.
			 * We remove it from the list of queued async inits and let it run in parallel to our queue. 
			 */
			var index:int = queuedInits.indexOf(def);
			if (index != -1) {
				log.warn("Unexpected parallel trigger of async initialization of " + def);
				queuedInits.splice(index, 1);
				parallelInits[instance] = def;
				parallelInitCount++;
				asyncObj.addEventListener(def.asyncInitConfig.completeEvent, parallelInstanceComplete);
				asyncObj.addEventListener(def.asyncInitConfig.errorEvent, parallelInstanceError);
			}
			else {
				// should never happen
				log.error("Unexpected async initialization of " + def);
			}
		}
	}
	
	
	private function activeInstanceComplete (event:Event) : void {
		removeListeners(IEventDispatcher(event.target), activeInstanceComplete, activeInstanceError);
		createNextInstance();
	}
	
	private function activeInstanceError (event:ErrorEvent) : void {
		removeListeners(IEventDispatcher(event.target), activeInstanceComplete, activeInstanceError);
		context.destroyWithError("Asynchronous initialization of " + activeDefinition + " failed", event);
	}
	
	private function parallelInstanceComplete (event:Event) : void {
		removeListeners(IEventDispatcher(event.target), parallelInstanceComplete, parallelInstanceError);
		removeParallelInit(event.target);
		if (complete) context.finishInitialization();
	}
	
	private function parallelInstanceError (event:ErrorEvent) : void {
		removeListeners(IEventDispatcher(event.target), parallelInstanceComplete, parallelInstanceError);
		var def:ObjectDefinition = removeParallelInit(event.target);
		context.destroyWithError("Asynchronous initialization of " + def + " failed", event);
	}
	
	private function removeParallelInit (instance:Object) : ObjectDefinition {
		var def:ObjectDefinition = parallelInits[instance];
		if (def != null) {
			delete parallelInits[instance];
			parallelInitCount--;
			if (complete) context.finishInitialization();
		}
		else {
			// should never happen
			log.warn("Internal error: Unexpected event for async-init instance of type " + getQualifiedClassName(instance));
		}
		return def;
	}

	private function removeListeners (asyncObj:IEventDispatcher, complete:Function, error:Function) : void {
		asyncObj.addEventListener(Event.COMPLETE, complete);
		asyncObj.addEventListener(ErrorEvent.ERROR, error);			
	}
	
	
}
}
