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

package org.spicefactory.parsley.core.task {
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ContextBuilderTask extends Task {
	
	
	private var _context:Context;
	private var parentContext:Context;
	private var domain:ApplicationDomain;


	function ContextBuilderTask (parent:Context = null, domain:ApplicationDomain = null) {
		this.parentContext = parent;
		this.domain = domain;
	}
	
	
	public function get result () : Context {
		return _context;
	}
	
	
	protected override function doStart () : void {
		var context:Context = build(parentContext, domain);
		if (context.initialized) {
			setResult(context);
		}
		else {
			context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);
		}
	}
	
	private function contextInitialized (event:ContextEvent) : void {
		setResult(event.target as Context);
	}
	
	protected function setResult (context:Context) : void {
		_context = context;
		complete();
	}
 
	
	protected function build (parent:Context = null, domain:ApplicationDomain = null) : Context {
		throw new AbstractMethodError();
	}
	
	
}
}
