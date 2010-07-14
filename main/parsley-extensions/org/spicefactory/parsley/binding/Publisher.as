package org.spicefactory.parsley.binding {
import flash.events.IEventDispatcher;
import org.spicefactory.lib.reflect.ClassInfo;

/**
 * Dispatched when the published value changes.
 * 
 * @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.event.Event")]

/**
 * Publishes a single value to matching subscribers.
 * The published value may change anytime, in which case a change event
 * must be dispatched by the publisher.
 * 
 * @author Jens Halm
 */
public interface Publisher extends IEventDispatcher {
	
	
	/**
	 * Initializes this publisher. The publisher is only supposed
	 * to dispatch change events and provide a published value
	 * after this method has been called until the dispose method is called.
	 */
	function init () : void;
	
	/**
	 * Disposes this publisher. After this method was invoked
	 * the publisher does not need to continue to provide a
	 * published value or dispatch change events.
	 */
	function dispose () : void;
	
	/**
	 * The type of the published value.
	 * May be an interface or supertype of the actual published value.
	 */
	function get type () : ClassInfo;
	
	/**
	 * The optional id of the published value.
	 * If omitted the subscribers and publishers will solely be matched by type.
	 */
	function get id () : String;
	
	/**
	 * The current value of this publisher. If this value changes the publisher
	 * must dispatch a change event.
	 */
	function get currentValue () : *;
	
	
}
}
