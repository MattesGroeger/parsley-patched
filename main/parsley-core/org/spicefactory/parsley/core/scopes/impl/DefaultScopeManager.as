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

package org.spicefactory.parsley.core.scopes.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.scopes.Scope;
import org.spicefactory.parsley.core.scopes.ScopeManager;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultScopeManager implements ScopeManager {
	
	
	private var scopes:Dictionary;
	private var domain:ApplicationDomain;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param scopes the scopes this instance should manage
	 */
	function DefaultScopeManager (scopes:Dictionary, domain:ApplicationDomain) {
		this.scopes = scopes;
		this.domain = domain;
	}

	
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
		for each (var scope:Scope in scopes) {
			scopes.push(scope);
		}
		return scopes;
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispatchMessage (message:Object, scope:String = null, selector:* = undefined) : void {
		if (scope == null) {
			for each (var sc:Scope in scopes) {
				sc.messageRouter.dispatchMessage(message, domain, selector);
			}
		}
		else {
			getScope(scope).messageRouter.dispatchMessage(message, domain, selector);
		}
	}
	
	
}
}
