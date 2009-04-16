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

package org.spicefactory.parsley.core {
import org.spicefactory.lib.events.NestedErrorEvent;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.impl.ChildContext;
import org.spicefactory.parsley.core.impl.DefaultContext;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;


/**
 * @author Jens Halm
 */
public class CompositeContextBuilder extends EventDispatcher {

	
	private var _context:DefaultContext;
	private var _parent:Context;
	private var _registry:ObjectDefinitionRegistry;
	private var _builders:Array = new Array();
	private var _currentBuilder:AsyncObjectDefinitionBuilder;

	
	function CompositeContextBuilder (parent:Context = null, domain:ApplicationDomain = null) {
		_parent = parent;
		_registry = new DefaultObjectDefinitionRegistry(domain);
		_context = (_parent != null) ? new ChildContext(_parent, _registry) : new DefaultContext(_registry);
		_context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		_builders.push(builder);
	}

	public function get domain () : ApplicationDomain {
		return _registry.domain;
	}
	
	public function get context () : Context {
		return _context;
	}

	public function build () : Context {
		invokeNextBuilder();
		return _context;	
	}
	
	private function invokeNextBuilder () : void {
		if (_builders.length == 0) {
			_context.initialize();
		}
		else {
			var builder:ObjectDefinitionBuilder = _builders.shift();
			try {
				if (builder is AsyncObjectDefinitionBuilder) {
					_currentBuilder = AsyncObjectDefinitionBuilder(builder);
					_currentBuilder.addEventListener(Event.COMPLETE, builderCompleted);				
					_currentBuilder.addEventListener(ErrorEvent.ERROR, builderError);				
					_currentBuilder.build(_registry);
				}
				else {
					builder.build(_registry);
					invokeNextBuilder();
				}
			} catch (e:Error) {
				dispatchBuilderError(builder, e);	
			}
		}
	}
	
	private function builderCompleted (event:Event) : void {
		invokeNextBuilder();
	}
	
	private function builderError (event:ErrorEvent) : void {
		dispatchBuilderError(event.target as ObjectDefinitionBuilder, event);
	}
	
	private function contextDestroyed (event:Event) : void {
		if (_currentBuilder != null) {
			_currentBuilder.cancel();
		}
	}
	
	private function dispatchBuilderError (builder:ObjectDefinitionBuilder, cause:Object) : void {
		var msg:String = "ObjectDefinitionBuilder " + builder + " failed";
		_context.dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, cause, msg));
	}
	
	
}

}
