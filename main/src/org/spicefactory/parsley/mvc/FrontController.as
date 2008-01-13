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
 
package org.spicefactory.parsley.mvc {
import flash.utils.getQualifiedClassName;

import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.mvc.impl.ActionRegistry;
import org.spicefactory.parsley.mvc.impl.DelegateAction;
import org.spicefactory.parsley.mvc.impl.Registry;
import org.spicefactory.parsley.mvc.impl.WrappedAction;

/**
 * The central class of the Parsley MVC Framework.
 * 
 * <p>This class allows you dispatch application events and to register 
 * actions and interceptors for those events.
 * It decouples the view and controller since they only communicate with each other through
 * application events dispatched by this controller.</p>
 * 
 * <p>In contrast to the <code>EventDispatcher</code> of the Core Flash Player API, the
 * <code>FrontController</code> allows you to filter events not only by String identifiers
 * but also by the event class. This gives you more fine-grained control especially in larger
 * applications where it might be difficult to guarantee unique event names.</p> 
 * 
 * <p>To allow this different filtering the FrontController uses instances of 
 * <code>ApplicationEvent</code> which is not a subclass of <code>flash.event.Event</code>. 
 * This differs from other parts of Parsley
 * which in general build upon the native Flash Event system.</p>
 * 
 * @author Jens Halm
 */
public class FrontController {

	private var actionsByType:Registry;
	private var actionsByName:Registry;
	private var actionsByTypeAndName:Registry;
	private var globalActions:Registry;
	
	private var interceptorsByType:Registry;
	private var interceptorsByName:Registry;
	private var interceptorsByTypeAndName:Registry;
	private var globalInterceptors:Registry;
	
	private var eventSources:Array;
	
	private static var _root:FrontController;
	
	
	/**
	 * The root <code>FrontController</code>. In many applications this may be
	 * the only active controller instance. But in general the framework does not force
	 * you to use the <code>FrontController</code> as a singleton. You can create and
	 * use as many instances as you want.
	 */
	public static function get root () : FrontController {
		if (_root == null) {
			_root = new FrontController(true);
		}
		return _root;
	}
	
	/**
	 * Creates a new instance.
	 * 
	 * @param useAsRoot Whether this instance should be available through FrontController.root
	 */
	function FrontController (useAsRoot:Boolean = false) {
		if (useAsRoot) {
			_root = this;
		}
		init();
	}
	
	
	private function init () : void {
		actionsByType = new ActionRegistry();
		actionsByName = new ActionRegistry();
		actionsByTypeAndName = new ActionRegistry();
		globalActions = new ActionRegistry();
		
		interceptorsByType = new Registry();
		interceptorsByName = new Registry();
		interceptorsByTypeAndName = new Registry();
		globalInterceptors = new Registry();		
		
		eventSources = new Array();
	}
	
	
	/**
	 * Dispatches the specified <code>ApplicationEvent</code> invoking all registered
	 * interceptors and actions for this event.
	 * 
	 * @param event the event to dispatch
	 */
	public function dispatchEvent (event:ApplicationEvent) : void {
		var name:String = event.name;
		var type:String = getQualifiedClassName(event);
		
		var actions:Array = globalActions.getItems("*")
			.concat(actionsByType.getItems(type))
			.concat(actionsByName.getItems(name))
			.concat(actionsByTypeAndName.getItems(type + "#" + name));
			
		var interceptors:Array = globalInterceptors.getItems("*")
			.concat(interceptorsByType.getItems(type))
			.concat(interceptorsByName.getItems(name))
			.concat(interceptorsByTypeAndName.getItems(type + "#" + name));
			
		var processor:ActionProcessor = new ActionProcessor(event, actions, interceptors);
		processor.proceed();
	}	
	
	
	/**
	 * Registers the specified <code>EventSource</code> with this controller.
	 * An <code>EventSource</code> allows you to adapt an existing class, which
	 * throws Flash Events (like PropertyChangeEvents for example) to act as
	 * an event source for this controller, with the Flash Event
	 * being transformed to an <code>ApplicationEvent</code> by the
	 * <code>EventTransformer</code> encapsulated in the source instance.
	 * 
	 * @param source the event source to register with this controller
	 */
	public function registerEventSource (source:EventSource) : void {
		source.activate(this);
		eventSources.push(source);
	}

	/**
	 * Registers the specified <code>Action</code> with this controller.
	 * 
	 * <p>Both the <code>eventClass</code> and the <code>eventName</code> parameters
	 * are optional. If both are null the action will be added as a global action
	 * executing on each <code>ApplicationEvent</code> which may be useful for 
	 * tasks like logging or monitoring. If only one parameter is null, the other
	 * will be used as the filter for determining the matching action. If both
	 * are specified only actions for which both the event class and the event name match
	 * will be executed.</p>
	 * 
	 * @param action the Action to register with this controller
	 * @param eventClass the (optional) event class this action should be registered for
	 * @param eventName the (optional) event name this action should be registered for
	 */
	public function registerAction (action:Action,
			eventClass:Class = null, eventName:String = null) : void {
		registerActionInstance(new WrappedAction(action), eventClass, eventName);		
	}

	/**
	 * Registers the specified function as an <code>Action</code> with this controller.
	 * 
	 * <p>This is an alternative for the <code>registerAction</code> method if you don't
	 * want to create a 1:1 mapping between events and action classes. This is useful
	 * if you want to bundle several similar actions in a single controller class. 
	 * Several MVC Frameworks
	 * force you to do the 1:1 mapping, with Parsley it is just an option.</p>
	 * 
	 * <p>Both the <code>eventClass</code> and the <code>eventName</code> parameters
	 * are optional. If both are null the action will be added as a global action
	 * executing on each <code>ApplicationEvent</code> which may be useful for 
	 * tasks like logging. If only one parameter is null, the other
	 * will be used as the filter for determining the matching action. If both
	 * are specified only actions for which both the event class and the event name match
	 * will be executed.</p>
	 * 
	 * @param action the Action to register with this controller
	 * @param eventClass the (optional) event class this function should be registered for
	 * @param eventName the (optional) event name this function should be registered for
	 */	
	public function registerActionDelegate (action:Function, 
			eventClass:Class = null, eventName:String = null) : void {
		registerActionInstance(new DelegateAction(action), eventClass, eventName);	
	}
	
	private function registerActionInstance (action:Action,
			eventClass:Class, eventName:String) : void {
		getActionRegistry(eventClass, eventName).registerItem(getKey(eventClass, eventName), action);
	}
	
	/**
	 * Registers the specified <code>ActionInterceptor</code> with this controller.
	 * 
	 * <p>Interceptors will always be executed before the registered actions.
	 * They allow you to interrupt the processing of the event, for example 
	 * to show an alert, and continue processing later depending on user interaction.
	 * They may as well decide to never proceed with the event processing, for security
	 * reasons for example.</p>
	 * 
	 * <p>Both the <code>eventClass</code> and the <code>eventName</code> parameters
	 * are optional. If both are null the interceptor will be added as a global interceptor
	 * executing on each <code>ApplicationEvent</code> which may be useful for 
	 * tasks like logging, monitoring or security. If only one parameter is null, the other
	 * will be used as the filter for determining the matching interceptor. If both
	 * are specified only interceptors for which both the event class and the event name match
	 * will be executed.</p>
	 * 
	 * @param ic the ActionInterceptor to register with this controller
	 * @param eventClass the (optional) event class this interceptor should be registered for
	 * @param eventName the (optional) event name this interceptor should be registered for
	 */
	public function registerInterceptor (ic:ActionInterceptor, 
			eventClass:Class = null, eventName:String = null) : void {
		getInterceptorRegistry(eventClass, eventName).registerItem(getKey(eventClass, eventName), ic);
	}
	
	
	/**
	 * Unregisters the specified <code>EventSource</code> with this <code>FrontController</code>.
	 * This will only work when you use the same instance like you used for registering.
	 * 
	 * @param source the event source to unregister with this controller
	 */
	public function unregisterEventSource (source:EventSource) : void {
		if (ArrayUtil.remove(eventSources, source)) {
			source.deactivate();
		}		
	}
	
	/**
	 * Unregisters the specified <code>Action</code> with this <code>FrontController</code>.
	 * 
	 * @param action the Action to unregister with this controller
	 * @param eventClass the (optional) event class this action was registered for
	 * @param eventName the (optional) event name this action was registered for
	 */
	public function unregisterAction (action:Action,
			eventClass:Class = null, eventName:String = null) : void {
		unregisterActionInstance(new WrappedAction(action), eventClass, eventName);
	}

	/**
	 * Unregisters the specified function with this <code>FrontController</code>.
	 * 
	 * @param action the function to unregister with this controller
	 * @param eventClass the (optional) event class this function was registered for
	 * @param eventName the (optional) event name this function was registered for
	 */	
	public function unregisterActionDelegate (action:Function, 
			eventClass:Class = null, eventName:String = null) : void {
		unregisterActionInstance(new DelegateAction(action), eventClass, eventName);		
	}
	
	private function unregisterActionInstance (action:Action,
			eventClass:Class, eventName:String) : void {
		getActionRegistry(eventClass, eventName).unregisterItem(getKey(eventClass, eventName), action);
	}
	
	/**
	 * Unregisters the specified <code>ActionInterceptor</code> with this <code>FrontController</code>.
	 * 
	 * @param action the interceptor to unregister with this controller
	 * @param eventClass the (optional) event class this interceptor was registered for
	 * @param eventName the (optional) event name this interceptor was registered for
	 */	
	public function unregisterInterceptor (ic:ActionInterceptor, 
			eventClass:Class = null, eventName:String = null) : void {
		getInterceptorRegistry(eventClass, eventName).unregisterItem(getKey(eventClass, eventName), ic);	
	}
	
	
	private function getKey (eventClass:Class, eventName:String) : String {
		if (eventClass != null && eventName != null) {
			return getQualifiedClassName(eventClass) + "#" + eventName;
		} else if (eventClass != null) {
			return getQualifiedClassName(eventClass);
		} else if (eventName != null) {
			return eventName;
		} else {
			return "*";
		}				
	}
	
	private function getActionRegistry (eventClass:Class, eventName:String) : Registry {
		if (eventClass != null && eventName != null) {
			return actionsByTypeAndName;
		} else if (eventClass != null) {
			return actionsByType;
		} else if (eventName != null) {
			return actionsByName;
		} else {
			return globalActions;
		}	
	}	
	
	private function getInterceptorRegistry (eventClass:Class, eventName:String) : Registry {
		if (eventClass != null && eventName != null) {
			return interceptorsByTypeAndName;
		} else if (eventClass != null) {
			return interceptorsByType;
		} else if (eventName != null) {
			return interceptorsByName;
		} else {
			return globalInterceptors;
		}	
	}	
	
	
	/**
	 * Destroys this <code>FrontController</code> instance, releasing all references
	 * and unregistering all event sources. If this <code>FrontController</code>
	 * was created by an <code>ApplicationContext</code> this method will be called
	 * automatically when the context gets destroyed.
	 */
	public function destroy () : void {
		for each (var source:EventSource in eventSources) {
			source.deactivate();
		}
		init();
		if (_root == this) {
			_root = null;
		}
	}

	
}

}

