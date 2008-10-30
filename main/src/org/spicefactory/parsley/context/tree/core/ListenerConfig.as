/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.tree.core {
import flash.events.IEventDispatcher;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the configuration for registration of an event listener
 * - in XML configuration the <code>&lt;listener&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class ListenerConfig 
	extends AbstractElementConfig implements ObjectProcessorConfig, ApplicationContextAware {

	
	private var _context:ApplicationContext;
	private var _dispatcher:String;
	private var _eventType:String;
	private var _method:String;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("dispatcher", StringConverter.INSTANCE, true);
			ep.addAttribute("event-type", StringConverter.INSTANCE, true);
			ep.addAttribute("method", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}

	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	
	public function set dispatcher (value:String) : void {
		_dispatcher = value;
	}
	
	/**
	 * The id of the object dispatching the event.
	 */
	public function get dispatcher () : String {
		if (_dispatcher != null) {
			return _dispatcher;
		} else {
			return getAttributeValue("dispatcher");
		}
	}
	
	
	public function set eventType (value:String) : void {
		_eventType = value;
	}
	
	/**
	 * The type of event.
	 */
	public function get eventType () : String {
		if (_eventType != null) {
			return _eventType;
		} else {
			return getAttributeValue("eventType");
		}
	}
	
	
	public function set method (value:String) : void {
		_method = value;
	}
	
	/**
	 * The name of the event listener method.
	 */
	public function get method () : String {
		if (_method != null) {
			return _method;
		} else {
			return getAttributeValue("method");
		}
	}
		

	/**
	 * Processes this configuration, registering the specified method as an event listener on
	 * the specified dispatcher.
	 * 
	 * @param obj the object acting as event listener
	 * @param ci the type information for the target instance
	 * @param destroyCommands the chain to add commands to that need to be processed when
	 * the ApplicationContext gets destroyed
	 */		
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		var dispatcherObject:Object = _context.getObject(dispatcher);
		if (dispatcherObject == null) {
			throw new ConfigurationError("No dispatcher object available with id " 
				+ dispatcher);
		}
		if (!(dispatcherObject is IEventDispatcher)) {
			throw new ConfigurationError("Object with id " + dispatcher 
				+ " does not implement IEventDispatcher");
		}
		if (!(obj[method] is Function)) {
			throw new ConfigurationError("Unable to resolve method '" + method 
				+ "' for given target object");
		}
		var listener:Function = obj[method];
		var target : IEventDispatcher = IEventDispatcher(dispatcherObject);
		target.addEventListener(eventType, listener);
		destroyCommands.addCommand(new Command(target.removeEventListener, [eventType, listener]));
	}
	
	
}

}
