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

package org.spicefactory.parsley.core.state.manager.impl {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.state.manager.GlobalContextManager;

import flash.utils.Dictionary;

/**
 * Default implementation of the GlobalContextManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultGlobalContextManager implements GlobalContextManager {
	
	
	private const contextMap:Dictionary = new Dictionary();
	private var domainManager:DefaultGlobalDomainManager;


	/**
	 * @private
	 */
	function DefaultGlobalContextManager (domainManager:DefaultGlobalDomainManager) {
		this.domainManager = domainManager;
	}

	/**
	 * @inheritDoc
	 */
	public function addContext (context:Context, config:BootstrapConfig, info:BootstrapInfo) : void {
		if (contextMap[context] != undefined) {
			throw new IllegalArgumentError("Context already registered: " + context);
		}
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
		contextMap[context] = new ContextRegistration(context, config, info);
		domainManager.addContext(context);
	}

	private function contextDestroyed (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		delete contextMap[context];
	}
	
	/**
	 * @inheritDoc
	 */
	public function getBootstrapInfo (context:Context) : BootstrapInfo {
		if (contextMap[context] == undefined) {
			throw new IllegalArgumentError("No Scopes registered for the specified Context instance");
		}
		return ContextRegistration(contextMap[context]).info;
	}

	/**
	 * @inheritDoc
	 */
	public function getBootstrapConfig (context:Context) : BootstrapConfig {
		if (contextMap[context] == undefined) {
			throw new IllegalArgumentError("No Scopes registered for the specified Context instance");
		}
		return ContextRegistration(contextMap[context]).config;
	}
	
	
}
}

import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.context.Context;

class ContextRegistration {
	
	public var context:Context;
	public var config:BootstrapConfig;
	public var info:BootstrapInfo;
	
	function ContextRegistration (context:Context, config:BootstrapConfig, info:BootstrapInfo) {
		this.context = context;
		this.config = config;
		this.info = info;
	}
	
}

	
