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
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.events.ContextEvent;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class CompositeContextBuilderTask extends Task {

	
	private var _builder:CompositeContextBuilder;

	
	function CompositeContextBuilderTask (parent:Context = null, domain:ApplicationDomain = null) {
		_builder = new CompositeContextBuilder(parent, domain);
	}
	
	
	public function get context () : Context {
		return _builder.context;
	}
	
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		_builder.addBuilder(builder);
	}
	
	
	protected override function doStart () : void {
		_builder.build();
		context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);		
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);		
		context.addEventListener(ErrorEvent.ERROR, contextError);		
	}
	
	private function contextInitialized (event:Event) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		complete();
	}
	
	private function contextDestroyed (event:Event) : void {
		// Destroyed before being fully initialized - interpreting this as cancellation
		cancel();
	}
	
	private function contextError (event:ErrorEvent) : void {
		error(event.text);
	}
	

}

}
