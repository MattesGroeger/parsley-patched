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
import org.spicefactory.parsley.core.messaging.Message;
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
	public function createCommand (returnValue:Object, message:Message) : Command {
		return new AsyncTokenCommand(AsyncToken(returnValue), message);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.command.impl.AbstractCommand;

import mx.rpc.AsyncToken;
import mx.rpc.Fault;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import flash.events.Event;

class AsyncTokenCommand extends AbstractCommand {

	private var token:AsyncToken;

	function AsyncTokenCommand (token:AsyncToken, message:Message) {
		super(token, message);
		this.token = token;
		token.addResponder(new Responder(complete, error));
		token.addEventListener(Event.CANCEL, operationCanceled);
		start();
	}
	
	protected function operationCanceled (event:Event) : void {
		removeListener();
		cancel();
	}
	
	protected override function complete (result:* = null) : void {
		removeListener();
		super.complete(result);
	}
	
	protected override function error (result:* = null) : void {
		removeListener();
		super.error(result);
	}
	
	private function removeListener () : void {
		token.removeEventListener(Event.CANCEL, operationCanceled);
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
