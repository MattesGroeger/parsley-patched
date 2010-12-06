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

package org.spicefactory.parsley.task.builder {
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;

import flash.display.DisplayObject;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

[Deprecated]
public class CompositeContextBuilderTask extends Task {

	private var _builder:CompositeContextBuilder;
	private var _context:Context;

	function CompositeContextBuilderTask (viewRoot:DisplayObject = null, parent:Context = null, domain:ApplicationDomain = null) {
		_builder = new DefaultCompositeContextBuilder(viewRoot, parent, domain);
	}
	
	public function get context () : Context {
		return _context;
	}
	
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		_builder.addBuilder(builder);
	}
	
	public function addProcessor (processor:ConfigurationProcessor) : void {
		_builder.addProcessor(processor);
	}
	
	protected override function doStart () : void {
		_context = _builder.build();
		if (!_context.initialized) {
			_context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);		
			_context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);		
			_context.addEventListener(ErrorEvent.ERROR, contextError);	
		}
		else {
			complete();	
		}
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
