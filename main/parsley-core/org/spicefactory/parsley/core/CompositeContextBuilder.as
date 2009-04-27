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
import org.spicefactory.parsley.core.builder.MetadataDecoratorExtractor;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
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

	
	private static const log:Logger = LogContext.getLogger(CompositeContextBuilder);

	
	private var _context:DefaultContext;
	private var _parent:Context;
	private var _registry:ObjectDefinitionRegistry;
	
	private var _builders:Array = new Array();
	private var _currentBuilder:AsyncObjectDefinitionBuilder;
	
	private var _errors:Array = new Array();
	private var async:Boolean = false;

	
	function CompositeContextBuilder (parent:Context = null, domain:ApplicationDomain = null) {
		_parent = parent;
		if (domain == null) domain = ApplicationDomain.currentDomain;
		MetadataDecoratorExtractor.initialize(domain);
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
		if (_builders.length > 0) {
			async = true;
		}
		return _context;	
	}
	
	private function invokeNextBuilder () : void {
		if (_builders.length == 0) {
			if (_errors.length > 0) {
				var errorMsg:String = "One or more errors processing CompositeContextBuilder: \n " + _errors.join("\n ");
				if (async) {
					_context.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMsg));
				}
				else {
					throw new ContextBuilderError(errorMsg);
				}
			}
			else {
				_context.initialize();
			}
		}
		else {
			var builder:ObjectDefinitionBuilder = _builders.shift();
			try {
				if (builder is AsyncObjectDefinitionBuilder) {
					_currentBuilder = AsyncObjectDefinitionBuilder(builder);
					_currentBuilder.addEventListener(Event.COMPLETE, builderComplete);				
					_currentBuilder.addEventListener(ErrorEvent.ERROR, builderError);		
					_currentBuilder.build(_registry);
				}
				else {
					builder.build(_registry);
					invokeNextBuilder();
				}
			} catch (e:Error) {
				removeCurrentBuilder();
				var msg:String = "Error processing " + builder;
				log.error(msg + "{0}", e);
				_errors.push(msg + ": " + e.message);
				invokeNextBuilder();
			}
		}
	}
	
	private function builderComplete (event:Event) : void {
		removeCurrentBuilder();
		invokeNextBuilder();
	}
	
	private function builderError (event:ErrorEvent) : void {
		removeCurrentBuilder();
		var msg:String = "Error processing " + event.target + ": " + event.text;
		log.error(msg);
		_errors.push(msg);
		invokeNextBuilder();
	}
	
	private function removeCurrentBuilder () : void {
		if (_currentBuilder == null) return;
		_currentBuilder.removeEventListener(Event.COMPLETE, builderComplete);				
		_currentBuilder.removeEventListener(ErrorEvent.ERROR, builderError);
		_currentBuilder = null;			
	}
	
	private function contextDestroyed (event:Event) : void {
		if (_currentBuilder != null) {
			_currentBuilder.cancel();
		}
	}
	
	
}

}
