package org.spicefactory.parsley.binding.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * Abstract base class for all Publisher implementations.
 * 
 * @author Jens Halm
 */
public class AbstractPublisher extends EventDispatcher {
	
	
	private var _type:ClassInfo;
	private var _id:String;

	private var currentObject:DynamicObject;
	private var context:Context;
	
	/**
	 * Indicates whether this publisher is currently enabled.
	 * When disabled changes to the current value should not cause
	 * a change event to be fired.
	 */
	protected var enabled:Boolean = true;
		
	
	/**
	 * Creates a new instance.
	 * 
	 * @param property the target property that holds the published value
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 * @param context the corresponding Context in case the published object should be managed
	 */
	function AbstractPublisher (property:Property, type:ClassInfo = null, id:String = null, context:Context = null) {
		this.context = context;
		_type = (type == null) ? property.type : type;
		_id = id;		
		this.context = context;
	}
	
	/**
	 * @copy org.spicefactory.parsley.binding.Publisher.type
	 */
	public function get type () : ClassInfo {
		return _type;
	}
	
	/**
	 * @copy org.spicefactory.parsley.binding.Publisher.id
	 */
	public function get id () : String {
		return _id;
	}
	
	/**
	 * Publishes a new value.
	 * 
	 * @param newValue the new value to publish
	 */
	protected function publish (newValue:*) : void {
		if (context) {
			if (currentObject) {
				 currentObject.remove();
				 currentObject = null;
			}
			if (newValue) {
				currentObject = context.addDynamicObject(newValue);
			}
		}
		if (enabled) dispatchEvent(new Event(Event.CHANGE));
	}
	
	
}
}
