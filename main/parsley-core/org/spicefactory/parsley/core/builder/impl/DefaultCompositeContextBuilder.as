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

package org.spicefactory.parsley.core.builder.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.metadata.MetadataDecoratorExtractor;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * Responsible for building Context instances using one or more ObjectDefinitionBuilder.
 * 
 * <p>This builder may be used when combining multiple configuration mechanisms like MXML or XML
 * into a single Context.</p>
 * 
 * <p>Example usage:</p>
 * 
 * <pre><code>var builder:CompositeContextBuilder = new CompositeContextBuilder();
 * FlexContextBuilder.merge(BookStoreConfig, builder);
 * XmlContextBuilder.merge("logging.xml", builder);
 * builder.build();</code></pre>	 
 * 
 * @author Jens Halm
 */
public class DefaultCompositeContextBuilder implements CompositeContextBuilder {

	
	private static const log:Logger = LogContext.getLogger(DefaultCompositeContextBuilder);

	
	private var _factories:FactoryRegistry;
	
	private var _context:DefaultContext;
	private var _parent:Context;
	private var _registry:ObjectDefinitionRegistry;
	
	private var _builders:Array = new Array();
	private var _currentBuilder:AsyncObjectDefinitionBuilder;
	
	private var _errors:Array = new Array();
	private var async:Boolean = false;

	
	/**
	 * Creates a new instance
	 * 
	 * @param parent the (optional) parent of the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 */
	function DefaultCompositeContextBuilder (parent:Context = null, domain:ApplicationDomain = null) {
		// TODO - 2.1.0 - create factories
		_parent = parent;
		if (domain == null) domain = ClassInfo.currentDomain;
		MetadataDecoratorExtractor.initialize(domain);
		_registry = new DefaultObjectDefinitionRegistry(domain);
		_context = (_parent != null) ? new ChildContext(_parent, _registry) : new DefaultContext(_registry);
		_context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function addBuilder (builder:ObjectDefinitionBuilder) : void {
		_builders.push(builder);
	}

	/**
	 * @inheritDoc
	 */
	public function get domain () : ApplicationDomain {
		return _registry.domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get context () : Context {
		return _context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get factories () : FactoryRegistry {
		return _factories;
	}

	/**
	 * @inheritDoc
	 */
	public function build () : Context {
		invokeNextBuilder();
		if (_builders.length > 0) {
			async = true;
		}
		return _context;	
	}
	
	private function invokeNextBuilder () : void {
		if (_builders.length == 0) {
			_context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
			if (_errors.length > 0) {
				handleErrors();
			}
			else {
				_context.addEventListener(ErrorEvent.ERROR, contextError);
				_context.initialize();
				_context.removeEventListener(ErrorEvent.ERROR, contextError);
				if (_errors.length > 0) {
					handleErrors();
				}
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
	
	private function handleErrors () : void {
		var errorMsg:String = "One or more errors processing CompositeContextBuilder: \n " + _errors.join("\n ");
		if (async) {
			_context.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMsg));
		}
		else {
			throw new ContextBuilderError(errorMsg);
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
	
	private function contextError (event:ErrorEvent) : void {
		var msg:String = "Error initializing Context: " + event.text;
		log.error(msg);
		_errors.push(msg);
	}
	
	private function contextDestroyed (event:Event) : void {
		_context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		if (_currentBuilder != null) {
			_currentBuilder.cancel();
		}
	}
	
	
}

}
