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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;

import flash.system.ApplicationDomain;

/**
 * Default implementation of the MessageRouter interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageRouter implements MessageRouter {
	
	
	private var _receivers:DefaultMessageReceiverRegistry;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the associated context instance
	 */
	function DefaultMessageRouter () {
		_receivers = new DefaultMessageReceiverRegistry();
	}

	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, domain:ApplicationDomain, selector:* = undefined) : void {
		if (domain == null) domain = ClassInfo.currentDomain;
		var messageType:ClassInfo = ClassInfo.forInstance(message, domain);
		var processor:MessageProcessor = new DefaultMessageProcessor(message, messageType, _receivers);
		processor.proceed();
	}	
	
	/**
	 * @inheritDoc
	 */
	public function get receivers () : MessageReceiverRegistry {
		return _receivers;
	}
	
	
}
}

