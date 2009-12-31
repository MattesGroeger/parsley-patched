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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;

/**
 * Internal facade interface that allows to decouple the default implementations
 * of MessageRouter and MessageProcessor interfaces. With the help of this
 * abstraction one could be swapped out without affecting the other.
 * 
 * @author Jens Halm
 */
public interface MessagingEnvironment {
	
	/**
	 * @copy org.spicefactory.parsley.core.factory.MessageRouterFactory#unhandledError
	 */
	function get unhandledError () : ErrorPolicy;
	
	/**
	 * @copy org.spicefactory.parsley.core.messaging.command.CommandFactoryRegistry#getCommandFactory()
	 */
	function getCommandFactory (type:Class) : CommandFactory;
	
	/**
	 * @copy org.spicefactory.parsley.core.messaging.command.impl.DefaultCommandManager#addActiveCommans()
	 */
	function addActiveCommand (command:Command) : void;
	
	/**
	 * @copy org.spicefactory.parsley.core.messaging.impl.DefaultMessageReceiverRegistry#getSelection()
	 */
	function getReceiverSelection (messageType:ClassInfo) : MessageReceiverSelection;
	
	
}
}
