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

package org.spicefactory.parsley.core.scope.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.InitializingService;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.scope.ScopeName;

import flash.utils.Dictionary;

/**
 * Default implementation of the ScopeManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultScopeManager implements ScopeManager, InitializingService {
	
	
	private var scopes:Dictionary = new Dictionary();
	private var nonLocalScopes:Array = new Array();
	
	
	/**
	 * @inheritDoc
	 */
	public function init (info:BootstrapInfo) : void {
		for each (var scope:ScopeInfo in info.scopes) {
			var s:Scope = new DefaultScope(info.context, scope, info.domain);
			scopes[scope.name] = s;
			if (scope.name != ScopeName.LOCAL) {
				nonLocalScopes.push(s);
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function hasScope (name:String) : Boolean {
		return (scopes[name] != undefined);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScope (name:String) : Scope {
		if (!hasScope(name)) {
			throw new IllegalArgumentError("This router does not contain a scope with name " + name);
		}
		return scopes[name] as Scope;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getAllScopes () : Array {
		var scopes:Array = new Array();
		for each (var scope:Scope in this.scopes) {
			scopes.push(scope);
		}
		return scopes;
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, selector:* = undefined) : void {
		DefaultScope(scopes[ScopeName.LOCAL]).broadcastMessage(message, selector, nonLocalScopes);
	}

	/**
	 * @inheritDoc
	 */
	public function observeCommand (command:Command) : void {
		DefaultScope(scopes[ScopeName.LOCAL]).observeCommand(command, nonLocalScopes);
	}
	
	
}
}
