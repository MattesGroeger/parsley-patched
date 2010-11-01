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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.MessageProcessor;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
import org.spicefactory.parsley.core.messaging.receiver.CommandTarget;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.receiver.MessageInterceptor;
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

/**
 * Default implementation of the MessageProcessor interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageProcessor implements MessageProcessor {
	
	
	private static const log:Logger = LogContext.getLogger(DefaultMessageProcessor);

	
	private var _message:Object;
	
	private var messageType:ClassInfo;
	private var selector:*;
	
	private var cache:MessageReceiverSelectionCache;
	private var remainingProcessors:Array;
	private var currentProcessor:Processor;
	private var currentError:Error;

	private var env:MessagingEnvironment;
	
	private var command:Command;
	private var status:CommandStatus;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param message the message to process
	 * @param messageType the type of the message
	 * @param cache the receiver selection cache corresponding to the messageType
	 * @param selector the selector to use (will be extracted from the message itself if it is undefined)
	 * @param env facade for the environment this processor operates in
	 * @param command the command in case this processor handles command observers
	 * @param status the status to handle the matching observers for
	 */
	function DefaultMessageProcessor (message:Object, messageType:ClassInfo, cache:MessageReceiverSelectionCache, 
			selector:*, env:MessagingEnvironment, command:Command = null, status:CommandStatus = null) {
		_message = message;
		this.messageType = messageType;
		this.cache = cache;
		this.selector = selector;
		this.env = env;
		this.command = command;
		this.status = (status != null) ? status : (command != null) ? command.status : null;
		rewind();
		if (!status && log.isInfoEnabled()) {
			var cnt:int = currentProcessor.receiverCount;
			if (remainingProcessors.length) cnt += Processor(remainingProcessors[0]).receiverCount;
			log.info("Dispatching message '{0}' to {1} receiver(s)", message, cnt);
		}
	}
	

	/**
	 * @inheritDoc
	 */
	public function proceed () : void {
		var async:Boolean;
		do {
			while (!currentProcessor.hasNext()) {
				if (remainingProcessors.length == 0) {
					currentProcessor = null;
					return;
				}
				currentProcessor = remainingProcessors.shift() as Processor;
			}
			async = currentProcessor.async;
			try {
				currentProcessor.proceed();
			}
			catch (e:Error) {
				log.error("Message Target threw Error {0}", e);
				if (!currentProcessor.handleErrors || (e is MessageProcessorError)) {
					// avoid the risk of endless loops
					throw e;
				}
				if (!handleError(e)) return;
			}
		} while (!async);
	}
	
	private function handleError (e:Error) : Boolean {
		var handlers:Array = new Array();
		var errorHandlers:Array = cache.getReceivers(MessageReceiverKind.ERROR_HANDLER, selector);
		for each (var errorHandler:MessageErrorHandler in errorHandlers) {
			if (e is errorHandler.errorType) {
				handlers.push(errorHandler);
			}
		}
		if (log.isInfoEnabled()) {
			log.info("Select " + handlers.length + " out of " + errorHandlers.length + " error handlers");
		}
		if (handlers.length > 0) {
			currentError = e;
			remainingProcessors.unshift(currentProcessor);
			currentProcessor = new Processor(handlers, invokeErrorHandler, true, false);
			return true;
		}
		else {
			return unhandledError(e);
		}
	}
	
	private function unhandledError (e:Error) : Boolean {
		if (env.unhandledError == ErrorPolicy.RETHROW) {
			throw new MessageProcessorError("Error in message receiver", e);
		}
		else if (env.unhandledError == ErrorPolicy.ABORT) {
			log.info("Unhandled error - abort message processor");
			return false;
		}
		else {
			log.info("Unhandled error - continue message processing");
			return true;
		}
	}
	
	
	private function invokeInterceptor (interceptor:MessageInterceptor) : void {
		interceptor.intercept(this);
	}
	
	private function invokeTarget (target:MessageReceiver) : void {
		if (target is MessageTarget) {
			MessageTarget(target).handleMessage(message);
		}
		else {
			invokeCommand(CommandTarget(target));
		}
	}
	
	private function invokeErrorHandler (errorHandler:MessageErrorHandler) : void {
		errorHandler.handleError(this, currentError);
	}
	
	private function invokeObserver (observer:CommandObserver) : void {
		observer.observeCommand(command);
	}
	
	private function invokeCommand (target:CommandTarget) : void {
		var factory:CommandFactory = env.getCommandFactory(target.returnType);
		var processor:DefaultCommandProcessor = new DefaultCommandProcessor(message, selector, factory);
		target.executeCommand(processor);
		var command:Command = processor.command;
		if (command != null) {
			env.addActiveCommand(command);
			command.addStatusHandler(handleCommand);
			handleCommand(command, CommandStatus.EXECUTE);
		}			
	}
	
	private function handleCommand (command:Command, status:CommandStatus = null) : void {	
		var processor:DefaultMessageProcessor 
				= new DefaultMessageProcessor(message, messageType, cache, selector, env, command, status);
		// TODO - optimize: skip when no matching observer
		if (log.isInfoEnabled()) {
			log.info("Dispatching message '{0}' for command status '{1}' to {2} observer(s)", 
				message, status, processor.currentProcessor.receiverCount);
		}
		processor.proceed();
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function rewind () : void {
		fetchReceivers();
	}
	
	private function fetchReceivers () : void {	
		if (command == null) {
			currentProcessor = newProcessor(MessageReceiverKind.INTERCEPTOR, invokeInterceptor, true);
			remainingProcessors = [newProcessor(MessageReceiverKind.TARGET, invokeTarget, false)];
		}
		else {
			var observers:Array = cache.getReceivers(MessageReceiverKind.forCommandStatus(status), selector);
			observers = command.getObservers(status).concat(observers);
			currentProcessor = new Processor(observers, invokeObserver, false);
			remainingProcessors = [];
		}
	}
	
	private function newProcessor (kind:MessageReceiverKind, handler:Function, async:Boolean) : Processor {
		var receivers:Array = cache.getReceivers(kind, selector);
		return new Processor(receivers, handler, async);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get message () : Object {
		return _message;
	}
	
	
}
}

import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.errors.NestedError;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.command.CommandProcessor;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;

class Processor {
	
	private var receivers:Array;
	private var handler:Function;
	private var currentIndex:uint = 0;
	internal var async:Boolean;
	internal var handleErrors:Boolean;
	
	function Processor (receivers:Array, handler:Function, async:Boolean = true, handleErrors:Boolean = true) {
		this.receivers = receivers;
		this.handler = handler;
		this.async = async;
		this.handleErrors = handleErrors;
		receivers.sortOn("order", Array.NUMERIC);
	}
	
	internal function hasNext () : Boolean {
		return (receivers.length > currentIndex);
	}
	
	internal function get receiverCount () : uint {
		return receivers.length;
	}

	internal function rewind () : void {
		currentIndex = 0;
	}

	internal function proceed () : void {
		handler(receivers[currentIndex++]);
	}
	
}

class MessageProcessorError extends NestedError {
	
	public function MessageProcessorError (message:String = "", cause:Error = null) {
		super(message, cause);
	}
	
}

class DefaultCommandProcessor implements CommandProcessor {

	private var _message:Object;
	private var selector:*;
	internal var command:Command;
	private var factory:CommandFactory;

	function DefaultCommandProcessor (message:Object, selector:*, factory:CommandFactory) {
		_message = message;
		this.selector = selector;
		this.factory = factory;
	}

	public function get message () : Object {
		return _message;
	}

	public function process (returnValue:*) : Command {
		if (command != null) {
			throw new IllegalStateError("process has already been called on this instance");
		}
		command = factory.createCommand(returnValue, message, selector);
		if (command == null) {
			throw new IllegalStateError("CommandFactory did not return a Command instance");
		}
		else if (command.status != CommandStatus.EXECUTE) {
			//throw new IllegalStateError("Initial status for Command must be EXECUTE: " + command);
		}
		return command;
	}
	
}



