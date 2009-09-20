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

package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class MessageRouterProxy implements MessageRouter {
	
	
	private var delegate:MessageRouter;	
	private var domain:ApplicationDomain;
	private var context:Context;
	
	private var deferredMessages:Array;
	private var activated:Boolean = false;
	
	
	
	function MessageRouterProxy (delegate:MessageRouter, context:Context, domain:ApplicationDomain) {
		if (context.initialized) {
			activated = true;
		}
		else {
			deferredMessages = new Array();
			context.addEventListener(ContextEvent.CONFIGURED, contextConfigured);
			context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		}
		this.context = context;
		this.domain = domain;
		this.delegate = delegate;
	}

	private function contextConfigured (event:ContextEvent) : void {
		removeListeners();
		activated = true;
		for each (var deferred:DeferredMessage in deferredMessages) {
			delegate.dispatchMessage(deferred.message, deferred.domain, deferred.selector);
		}
		deferredMessages = new Array();
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		removeListeners();
	}
	
	private function removeListeners () : void {
		context.removeEventListener(ContextEvent.CONFIGURED, contextConfigured);
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, domain:ApplicationDomain = null, selector:* = undefined) : void {
		if (!activated) {
			deferredMessages.push(new DeferredMessage(message, domain, selector));
		}
		else {
			domain = (domain == null) ? this.domain : domain;
			delegate.dispatchMessage(message, domain, selector);
		}
	}	

	/**
	 * @inheritDoc
	 */
	public function addTarget (target:MessageTarget) : void {
		delegate.addTarget(target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeTarget (target:MessageTarget) : void {
		delegate.removeTarget(target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addInterceptor (interceptor:MessageInterceptor) : void {
		delegate.addInterceptor(interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeInterceptor (interceptor:MessageInterceptor) : void {
		delegate.removeInterceptor(interceptor);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addErrorHandler (errorHandler:MessageErrorHandler) : void {
		delegate.addErrorHandler(errorHandler);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeErrorHandler (errorHandler:MessageErrorHandler) : void {
		delegate.removeErrorHandler(errorHandler);
	}
	

}
}

import flash.system.ApplicationDomain;

class DeferredMessage {
	internal var message:Object;
	internal var domain:ApplicationDomain;
	internal var selector:*;
	function DeferredMessage (message:Object, domain:ApplicationDomain, selector:*) {
		this.message = message;
		this.domain = domain;
		this.selector = selector;
	}
}

