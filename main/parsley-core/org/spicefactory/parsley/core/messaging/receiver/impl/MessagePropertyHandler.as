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

package org.spicefactory.parsley.core.messaging.receiver.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.provider.ObjectProvider;

[Deprecated(replacement="MessageHandler")]
/**
 * @author Jens Halm
 */
public class MessagePropertyHandler extends MessageHandler {
	
	function MessagePropertyHandler (provider:ObjectProvider, methodName:String, messageType:ClassInfo,
			messageProperties:Array, selector:* = undefined) {
		super(provider, methodName, selector, messageType, messageProperties);
	}

}
}
