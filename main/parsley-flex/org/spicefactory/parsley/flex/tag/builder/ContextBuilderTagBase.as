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

package org.spicefactory.parsley.flex.tag.builder {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.events.NestedErrorEvent;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.events.ContextBuilderEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.factory.ContextBuilderFactory;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.flex.tag.ConfigurationTagBase;

import flash.display.DisplayObject;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * Dispatched when the Context built by this tag was fully initialized.
 * 
 * @eventType org.spicefactory.parsley.flex.tag.builder.FlexContextEvent.INITIALIZED
 */
[Event(name="complete", type="org.spicefactory.parsley.flex.tag.builder.FlexContextEvent")]

/**
 * Dispatched when building the Context failed. 
 * 
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]
/**
 * Base class for all MXML tags for declaratively creating a Parsley Context.
 * 
 * @author Jens Halm
 */
public class ContextBuilderTagBase extends ConfigurationTagBase {


	/**
	 * The parent to use for the Context to build.
	 * Will usually automatically detected in the view hierarchy and only has to be specified
	 * if this is not possible, for example when the parent Context is not associated with
	 * a view root DisplayObject.
	 */
	public var parent:Context;
	
	/**
	 * The ApplicationDomain to use for reflection.
	 * Will usually automatically detected and only has to be specified if the domain
	 * is neither the root ApplicationDomain nor a domain that was used to load a Flex module.
	 */
	public var domain:ApplicationDomain;
	
	/**
	 * The initial view root for dynamically wiring view objects.
	 * Should not be specified explicitly in most cases. If this property is not set
	 * the tag will use the associated document instance as a view root.
	 */
	public var viewRoot:DisplayObject;
	
	/**
	 * Extensions that should be initialized before the Context gets built.
	 */
	public var extensions:Array;
	
	/**
	 * Custom scopes that should be added to the Context.
	 */
	public var scopes:Array;
	
	
	
	private var cachedViewConfigEvents:Array = new Array();
	private var synchronizedChildEvents:Array = new Array();
	
	private var _context:Context;
	
	[Bindable("contextCreated")]
	/**
	 * The Context built by this tag. May be null before the tag performed its work.
	 * The value may be used for bindings. 
	 */
	public function get context () : Context {
		return _context;
	}


	/**
	 * @private
	 */
	public override function initialized (document:Object, id:String) : void {
		super.initialized(document, id);
		if (_context == null) {
			addViewRootListeners(DisplayObject(document));
		}
	}
	
	private function addViewRootListeners (view:DisplayObject) : void {
		view.addEventListener(ContextBuilderEvent.BUILD_CONTEXT, detectPrematureChildCreation);
		view.addEventListener(ViewConfigurationEvent.CONFIGURE_VIEW, cacheViewConfigEvent);
		view.addEventListener(ContextBuilderSyncEvent.SYNC_BUILDER, syncChildContext);
	}
	
	private function removeViewRootListeners (view:DisplayObject) : void {
		view.removeEventListener(ContextBuilderEvent.BUILD_CONTEXT, detectPrematureChildCreation);
		view.removeEventListener(ViewConfigurationEvent.CONFIGURE_VIEW, cacheViewConfigEvent);
		view.removeEventListener(ContextBuilderSyncEvent.SYNC_BUILDER, syncChildContext);
	}
	
	private function syncChildContext (event:ContextBuilderSyncEvent) : void {
		event.stopImmediatePropagation();
		if (_context == null) {
			event.deferred = true;
			synchronizedChildEvents.push(event);
		}
	}
	
	private function detectPrematureChildCreation (event:ContextBuilderEvent) : void {
		event.stopImmediatePropagation();
		throw new ContextBuilderError("Child Context created before parent is initialized");
	}
	
	private function cacheViewConfigEvent (event:ViewConfigurationEvent) : void {
		event.stopImmediatePropagation();
		cachedViewConfigEvents.push(event);
	}
	
	private function handleCachedEvents () : void {
		for each (var viewEvent:ViewConfigurationEvent in cachedViewConfigEvents) {
			viewEvent.target.dispatchEvent(viewEvent.clone());
		}
		cachedViewConfigEvents = new Array();
		for each (var syncEvent:ContextBuilderSyncEvent in synchronizedChildEvents) {
			syncEvent.callback();
		}
		synchronizedChildEvents = new Array();
	}
	
	
	/**
	 * @private
	 */
	protected override function executeAction (view:DisplayObject) : void {
		removeViewRootListeners(view);
		if (viewRoot == null) {
			viewRoot = view;
		}
		var syncEvent:ContextBuilderSyncEvent = new ContextBuilderSyncEvent(createContextDeferred);
		viewRoot.dispatchEvent(syncEvent);
		if (syncEvent.deferred) {
			addViewRootListeners(viewRoot);
		}
		else {
			createContext();
		}
	}
	
	private function createContextDeferred () : void {
		removeViewRootListeners(viewRoot);
		createContext();
	}
	
	private function createContext () : void {
		try {
			var factory:ContextBuilderFactory = GlobalFactoryRegistry.instance.contextBuilder;
			var builder:CompositeContextBuilder = factory.create(viewRoot, parent, domain);
			if (extensions != null) {
				for each (var extension:Extension in extensions) {
					extension.initialize(builder);
				}
			}
			if (scopes != null) {
				for each (var scopeTag:ScopeTag in scopes) {
					builder.addScope(scopeTag.name, scopeTag.inherited);
				}
			}
			addBuilders(builder);
			_context = builder.build();
			dispatchEvent(new Event("contextCreated"));
			if (_context.initialized) {
				dispatchEvent(new FlexContextEvent(_context));
			}
			else {
				_context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);
				_context.addEventListener(ErrorEvent.ERROR, contextError);
			}
			handleCachedEvents();
		}
		catch (e:Error) {
			dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, e));
		}
	}
	
	private function contextInitialized (event:Event) : void {
		removeContextListeners();
		dispatchEvent(new FlexContextEvent(_context));
	}
	
	private function contextError (event:ErrorEvent) : void {
		removeContextListeners();
		_context = null;
		dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, event));
	}

	private function removeContextListeners () : void {
		_context.removeEventListener(ContextEvent.INITIALIZED, contextInitialized);
		_context.removeEventListener(ErrorEvent.ERROR, contextError);
	}
	
	
	/**
	 * Adds the builders to use to the specified (empty) builder instance.
	 * The implementation of this base class throws an Error, subclasses are
	 * expected to override this method.
	 * 
	 * @param builder the builder that will be used to create the Context 
	 */
	protected function addBuilders (builder:CompositeContextBuilder) : void {
		throw new AbstractMethodError();
	}
	
	
}
}
