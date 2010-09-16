package org.spicefactory.parsley.flash.binding {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.Publisher;
import org.spicefactory.parsley.binding.impl.AbstractPublisher;
import org.spicefactory.parsley.core.context.Context;

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * A Publisher that observes the value of a single property and uses its value
 * as the published value. 
 * 
 * This implementation does not rely on the Flex Binding facility so that it can be used in Flash applications.
 * 
 * @author Jens Halm
 */
public class FlashPropertyPublisher extends AbstractPublisher implements Publisher {
	
	
	private var target:Object;
	private var property:Property;
	
	private var changeEvent:String;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param target the instance that holds the property to observe
	 * @param property the target property that holds the published value
	 * @param changeEvent the event type that signals that the property value has changed
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 * @param context the corresponding Context in case the published object should be managed
	 */
	function FlashPropertyPublisher (target:Object, property:Property, changeEvent:String, type:ClassInfo = null, id:String = null,
			context:Context = null) {
		super(type ? type : property.type, id, false, context);
		this.target = target;
		this.property = property;
		this.changeEvent = changeEvent;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function init () : void {
		(IEventDispatcher(target)).addEventListener(changeEvent, propertyChanged);
	}
	
	private function propertyChanged (event:Event) : void {
		publish(currentValue);
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose () : void {
		(IEventDispatcher(target)).removeEventListener(changeEvent, propertyChanged);
		enabled = false;
		publish(null);
	}

	/**
	 * @inheritDoc
	 */
	public function get currentValue () : * {
		return property.getValue(target);
	}
	
	
}
}
