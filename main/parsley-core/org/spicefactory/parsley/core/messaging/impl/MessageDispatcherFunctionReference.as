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

package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.parsley.core.messaging.MessageRouter;

import flash.system.ApplicationDomain;

/**
 * Represents a reference to a message dispatcher function. To be used in MXML and XML configuration.
 * 
 * @author Jens Halm
 */
public class MessageDispatcherFunctionReference {
	
	/**
	 * The ApplicationDomain to pass to the MessageRouter for reflecting on message types.
	 */
	public var domain:ApplicationDomain;
	
	/**
	 * The MessageRouter to use for dispatching messages.
	 */
	public var router:MessageRouter;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param domain the ApplicationDomain to pass to the MessageRouter
	 */
	function MessageDispatcherFunctionReference (domain:ApplicationDomain = null) {
		this.domain = domain;
	}
	
	
	/**
	 * Dispatches the specified message through the MessageRouter associated with this reference.
	 * 
	 * @param message the message to dispatch
	 */
	public function dispatchMessage (message:Object) : void {
		router.dispatchMessage(message, domain);
	}
	
	
}
}
