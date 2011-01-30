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
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import flash.utils.getQualifiedClassName;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.bootstrap.BootstrapManager;
import org.spicefactory.lib.events.NestedErrorEvent;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.events.ContextConfigurationEvent;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.FastInjectEvent;
import org.spicefactory.parsley.core.events.ViewConfigurationEvent;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.view.handler.AutowirePrefilterCache;
import org.spicefactory.parsley.core.events.ContextLookupEvent;
import org.spicefactory.parsley.flex.FlexSupport;
import org.spicefactory.parsley.flex.processor.FlexConfigurationProcessor;
import org.spicefactory.parsley.flex.resources.FlexResourceBindingAdapter;
import org.spicefactory.parsley.flex.tag.ConfigurationTagBase;
import org.spicefactory.parsley.processor.resources.ResourceBindingProcessor;

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

[DefaultProperty("processors")]
/**
 * MXML tag for creating a Parsley Context. In the most simple use case where
 * only a single MXML configuration class is used, it can be specified with the config 
 * attribute:
 * <pre><code>&lt;parsley:ContextBuilder config="{BookStoreConfig}"/&gt;</code></pre>
 *  
 * <p>When combining multiple configuration mechanism or when a custom scope or extension
 * must be specified, the corresponding child tags can be used:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlConfig file="logging.xml"/&gt;
 *     &lt;parsley:Scope name="window" inherited="true"/&gt;
 *     &lt;parsley:FlexLoggingXmlSupport/&gt;
 * &lt;/parsley:ContextBuilder&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public class ContextBuilderTag extends ConfigurationTagBase {


	private static const log:Logger = LogContext.getLogger(ContextBuilderTag);
	

	ResourceBindingProcessor.adapterClass = FlexResourceBindingAdapter;
	

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
	 * A class that contains MXML configuration for this Context.
	 * This parameter is optional, configuration artifacts can also be added with child tags
	 * like <code>&lt;FlexConfig&gt;</code> or <code>&lt;XmlConfig&gt;</code>.
	 */
	public var config:Class;
	
	/**
	 * A description to be passed to the Context for logging or monitoring purposes.
	 */
	public var description:String;
	
	[ArrayElementType("org.spicefactory.parsley.flex.tag.builder.ContextBuilderChildTag")]
	/**
	 * The individual configuration artifacts for this ContextBuilder.
	 */
	public var processors:Array;
	
	
	private var cachedContextLookupEvents:Array = new Array();
	private var cachedViewConfigEvents:Array = new Array();
	private var cachedFastInjectEvents:Array = new Array();
	private var cachedAutowireViewEvents:Array = new Array();
	private var cachedAutowirePrefilterTargets:Array = new Array();
	private var synchronizedChildEvents:Array = new Array();
	private var autowireViewEventType:String;
	
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
		FlexSupport.initialize();
		if (document is DisplayObject) {
			cachedAutowirePrefilterTargets.push(document);
		}
		super.initialized(document, id);
		if (_context == null) {
			autowireViewEventType = BootstrapDefaults.config.viewSettings.autowireFilter.eventType;
			addViewRootListeners(DisplayObject(document));
		}
	}
	
	private function addViewRootListeners (view:DisplayObject) : void {
		view.addEventListener(ContextConfigurationEvent.CONFIGURE_CONTEXT, detectPrematureChildCreation);
		view.addEventListener(ContextLookupEvent.LOOKUP, cacheContextLookupEvent);
		view.addEventListener(ViewConfigurationEvent.CONFIGURE_VIEW, cacheViewConfigEvent);
		view.addEventListener(autowireViewEventType, cacheAutowirePrefilterEvent);
		view.addEventListener(autowireViewEventType, cacheAutowirePrefilterEvent, true);
		view.addEventListener(ViewConfigurationEvent.AUTOWIRE_VIEW, cacheAutowireViewEvent);
		view.addEventListener(FastInjectEvent.FAST_INJECT, cacheFastInjectEvent);
		view.addEventListener(ContextBuilderSyncEvent.SYNC_BUILDER, syncChildContext);
	}
	
	private function removeViewRootListeners (view:DisplayObject) : void {
		view.removeEventListener(ContextConfigurationEvent.CONFIGURE_CONTEXT, detectPrematureChildCreation);
		view.removeEventListener(ContextLookupEvent.LOOKUP, cacheContextLookupEvent);
		view.removeEventListener(ViewConfigurationEvent.CONFIGURE_VIEW, cacheViewConfigEvent);
		view.removeEventListener(autowireViewEventType, cacheAutowirePrefilterEvent);
		view.removeEventListener(autowireViewEventType, cacheAutowirePrefilterEvent, true);
		view.removeEventListener(ViewConfigurationEvent.AUTOWIRE_VIEW, cacheAutowireViewEvent);
		view.removeEventListener(FastInjectEvent.FAST_INJECT, cacheFastInjectEvent);
		view.removeEventListener(ContextBuilderSyncEvent.SYNC_BUILDER, syncChildContext);
	}
	
	private function syncChildContext (event:ContextBuilderSyncEvent) : void {
		event.stopImmediatePropagation();
		if (_context == null) {
			event.deferred = true;
			synchronizedChildEvents.push(event);
		}
	}
	
	private function detectPrematureChildCreation (event:ContextConfigurationEvent) : void {
		event.stopImmediatePropagation();
		throw new ContextBuilderError("Child Context created before parent is initialized");
	}
	
	private function cacheViewConfigEvent (event:Event) : void {
		event.stopImmediatePropagation();
		cachedViewConfigEvents.push(event);
		if (event is ViewConfigurationEvent) {
			ViewConfigurationEvent(event).markAsProcessed();
		}
	}
	
	private function cacheContextLookupEvent (event:ContextLookupEvent) : void {
		event.stopImmediatePropagation();
		cachedContextLookupEvents.push(event);
		event.markAsProcessed();
	}
	
	private function cacheFastInjectEvent (event:FastInjectEvent) : void {
		event.stopImmediatePropagation();
		cachedFastInjectEvents.push(event);
		event.markAsReceived();
	}
	
	private function cacheAutowirePrefilterEvent (event:Event) : void {
		if (!AutowirePrefilterCache.addEvent(event)) return;
		cachedAutowirePrefilterTargets.push(event.target);
	}
	
	private function cacheAutowireViewEvent (event:Event) : void {
		event.stopImmediatePropagation();
		cachedAutowireViewEvents.push(event);
	}
	
	private function handleCachedEvents (config:BootstrapConfig) : void {
		for each (var lookupEvent:ContextLookupEvent in cachedContextLookupEvents) {
			lookupEvent.context = _context;
		}
		for each (var viewEvent:Event in cachedViewConfigEvents) {
			viewEvent.target.dispatchEvent(viewEvent.clone());
		}
		for each (var fastInject:Event in cachedFastInjectEvents) {
			fastInject.target.dispatchEvent(fastInject.clone());
		}
		for each (var autowireEvent:Event in cachedAutowireViewEvents) {
			autowireEvent.target.dispatchEvent(autowireEvent.clone());
		}
		for each (var prefilterTarget:Object in cachedAutowirePrefilterTargets) {
			var view:DisplayObject = DisplayObject(prefilterTarget);
			var autowireFilter:ViewAutowireFilter = config.viewSettings.autowireFilter;
			if (autowireFilter.prefilter(view)) {
				view.dispatchEvent(ViewConfigurationEvent.forAutowiring(view));
			}
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
			var manager:BootstrapManager = BootstrapDefaults.config.services.bootstrapManager.newInstance() as BootstrapManager;
			if (viewRoot) manager.config.viewRoot = viewRoot;
			if (parent) manager.config.parent = parent;
			if (domain) manager.config.domain = domain;
			if (description) manager.config.description = description;
			var builder:CompositeContextBuilder; // don't create upfront, hope we don't need it
			if (processors != null) {
				for each (var processor:ContextBuilderChildTag in processors) {
					if (processor is BootstrapConfigProcessor) {
						BootstrapConfigProcessor(processor).processConfig(manager.config);
					}
					else if (processor is ContextBuilderProcessor) {
						/* deprecated - remove in later versions */
						if (!builder) {
							builder = new DefaultCompositeContextBuilder(viewRoot, parent, domain, description, manager);
						}
						ContextBuilderProcessor(processor).processBuilder(builder);
					}
					else {
						throw Error("Unknown type of child tag for ContextBuilder: " + getQualifiedClassName(processor));
					}
				}
			}
			if (config != null) {
				manager.config.addProcessor(new FlexConfigurationProcessor([config]));
			}
			_context = manager.createProcessor().process();
			dispatchEvent(new Event("contextCreated"));
			if (_context.initialized) {
				dispatchEvent(new FlexContextEvent(_context));
			}
			else {
				_context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);
				_context.addEventListener(ErrorEvent.ERROR, contextError);
			}
			handleCachedEvents(manager.config);
		}
		catch (e:Error) {
			log.error("Error building Context: {0}", e);
			dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, e, "Error building Context"));
		}
	}
	
	private function contextInitialized (event:Event) : void {
		removeContextListeners();
		dispatchEvent(new FlexContextEvent(_context));
	}
	
	private function contextError (event:ErrorEvent) : void {
		removeContextListeners();
		_context = null;
		log.error("Error building Context: {0}", event.text);
		dispatchEvent(new NestedErrorEvent(ErrorEvent.ERROR, event, "Error building Context"));
	}

	private function removeContextListeners () : void {
		_context.removeEventListener(ContextEvent.INITIALIZED, contextInitialized);
		_context.removeEventListener(ErrorEvent.ERROR, contextError);
	}
	
	
}
}
