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

package org.spicefactory.parsley.core.factory.impl {
import org.spicefactory.lib.reflect.types.Void;
import org.spicefactory.parsley.core.factory.MessageSettings;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.command.CommandFactoryRegistry;
import org.spicefactory.parsley.core.messaging.command.impl.SynchronousCommandFactory;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;

/**
 * Default implementation of the MessageSettings interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageSettings implements MessageSettings {


	private var _parent:MessageSettings;
	
	private var _unhandledError:ErrorPolicy;
	private var _errorHandlers:Array = new Array();
	private var _commandFactories:DefaultCommandFactoryRegistry;


	/**
	 * @private
	 */
	function DefaultMessageSettings () {
		_commandFactories = new DefaultCommandFactoryRegistry();
		_commandFactories.addCommandFactory(Void, new SynchronousCommandFactory());
	}

	
	public function set parent (parent:MessageSettings) : void {
		_parent = parent;
		_commandFactories.parent = parent.commandFactories;
	}

	
	/**
	 * @inheritDoc
	 */
	public function addErrorHandler (target:MessageErrorHandler) : void {
		_errorHandlers.push(target);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get errorHandlers () : Array {
		var handlers:Array = _errorHandlers;
		if (_parent) {
			handlers = handlers.concat(_parent.errorHandlers);
		}
		return handlers;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get unhandledError () : ErrorPolicy {
		return (_unhandledError) 
				? _unhandledError 
				: ((_parent) ? _parent.unhandledError : ErrorPolicy.IGNORE);
	}
	
	/**
	 * @inheritDoc
	 */
	public function set unhandledError (policy:ErrorPolicy) : void {
		_unhandledError = policy;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addCommandFactory (type:Class, factory:CommandFactory) : void {
		_commandFactories.addCommandFactory(type, factory);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get commandFactories () : CommandFactoryRegistry {
		return _commandFactories;
	}
}
}

import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.command.CommandFactoryRegistry;

import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

class DefaultCommandFactoryRegistry implements CommandFactoryRegistry {

	private var factoryMap:Dictionary = new Dictionary();
	private var _parent:CommandFactoryRegistry;
	
	public function set parent (parent:CommandFactoryRegistry) : void {
		_parent = parent;
	}

	public function addCommandFactory (type:Class, factory:CommandFactory) : void {
		if (factoryMap[type] != undefined) {
			throw new IllegalArgumentError("Duplicate CommandFactory registration for return type " 
					+ getQualifiedClassName(type));
		}
		factoryMap[type] = factory;
	}

	public function getCommandFactory (type:Class) : CommandFactory {
		if (factoryMap[type] == undefined) {
			if (_parent) {
				return _parent.getCommandFactory(type);
			}
			throw new IllegalArgumentError("No CommandFactory registered for return type " 
					+ getQualifiedClassName(type));
		}
		return factoryMap[type] as CommandFactory;
	}
	
}


