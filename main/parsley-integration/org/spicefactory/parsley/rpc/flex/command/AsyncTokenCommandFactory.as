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

package org.spicefactory.parsley.rpc.flex.command {
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;

import mx.rpc.AsyncToken;

/**
 * CommandFactory implementation that supports command methods that
 * return an AsyncToken.
 * 
 * @author Jens Halm
 */
public class AsyncTokenCommandFactory implements CommandFactory {

	/**
	 * @inheritDoc
	 */
	public function createCommand (returnValue:Object, message:Object, selector:* = undefined) : Command {
		return new AsyncTokenCommand(AsyncToken(returnValue), message, selector);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.command.impl.AbstractCommand;

import mx.rpc.AsyncToken;
import mx.rpc.Fault;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

class AsyncTokenCommand extends AbstractCommand {


	function AsyncTokenCommand (token:AsyncToken, message:Object, selector:*) {
		super(token, message, selector);
		token.addResponder(new Responder(complete, error));
		start();
	}
	
	protected override function selectResultValue (result:*, targetType:ClassInfo) : * {
		return (targetType.getClass() != ResultEvent && result is ResultEvent) 
			? ResultEvent(result).result
			: result;
	}
	
	protected override function selectErrorValue (result:*, targetType:ClassInfo) : * {
		return (targetType.getClass() == Fault && result is FaultEvent)
			? FaultEvent(result).fault
			: result;
	}
	
	
}
