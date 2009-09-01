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
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.events.ContextCreationEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.factory.FactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.factory.impl.LocalFactoryRegistry;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

import flash.display.DisplayObject;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * Responsible for building Context instances using one or more ObjectDefinitionBuilder.
 * 
 * <p>This builder may be used when combining multiple configuration mechanisms like MXML or XML
 * into a single Context. It is also used by all short cut entry points that only use a single
 * configuration mechanism under the hood.</p>
 * 
 * <p>Example usage:</p>
 * 
 * <pre><code>var builder:CompositeContextBuilder = new DefaultCompositeContextBuilder();
 * FlexContextBuilder.merge(BookStoreConfig, builder);
 * XmlContextBuilder.merge("logging.xml", builder);
 * builder.build();</code></pre>	 
 * 
 * @author Jens Halm
 */
public class DefaultCompositeContextBuilder implements CompositeContextBuilder {

	
	private static const log:Logger = LogContext.getLogger(DefaultCompositeContextBuilder);

	
	private var _factories:FactoryRegistry;
	
	private var _viewRoot:DisplayObject;
	private var _context:Context;
	private var _parent:Context;
	private var _domain:ApplicationDomain;
	private var _registry:ObjectDefinitionRegistry;
	
	private var _builders:Array = new Array();
	private var _currentBuilder:AsyncObjectDefinitionBuilder;
	
	private var _errors:Array = new Array();
	private var async:Boolean = false;

	
	/**
	 * Creates a new instance
	 * 
	 * @param viewRoot the initial view root to manage for the Context this instance creates
	 * @param parent the (optional) parent of the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 */
	function DefaultCompositeContextBuilder (viewRoot:DisplayObject = null, parent:Context = null, domain:ApplicationDomain = null) {
		_factories = new LocalFactoryRegistry(GlobalFactoryRegistry.instance);
		_viewRoot = viewRoot;
		var event:ContextCreationEvent = null;
		if ((parent == null || domain == null) && viewRoot != null) {
			event = new ContextCreationEvent();
			viewRoot.dispatchEvent(event);
		}
		_parent = (parent != null) ? parent : (event != null) ? event.parent : null;
		_domain = (domain != null) ? domain : (event != null && event.domain != null) ? event.domain : ClassInfo.currentDomain;
	}
	
	
	private function initialize () : void {
		_registry = _factories.definitionRegistry.create(domain);
		_context = _factories.context.create(_factories, _registry, _viewRoot, _parent);
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
		return _domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get context () : Context {
		if (_context == null) initialize();
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
		if (_context == null) initialize();
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
				_registry.freeze();
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
