package org.spicefactory.parsley.binding.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.Publisher;
import org.spicefactory.parsley.core.context.Context;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;

/**
 * A Publisher that observes the value of a single property and uses its value
 * as the published value. This implementation relies on the Flex Binding facility.
 * For Flash applications you can use the <code>FlashPropertyPublisher</code> implementation.
 * 
 * @author Jens Halm
 */
public class PropertyPublisher extends AbstractPublisher implements Publisher {
	
	
	private var target:Object;
	private var propertyName:String;
	
	private var _currentValue:*;
	private var changeWatcher:ChangeWatcher;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param target the instance that holds the property to observe
	 * @param property the target property that holds the published value
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 * @param context the corresponding Context in case the published object should be managed
	 */
	function PropertyPublisher (target:Object, property:Property, type:ClassInfo = null, id:String = null,
			context:Context = null) {
		super(property, type, id, context);
		this.target = target;
		this.propertyName = property.name;
		propertyName = property.name;
	}

	/**
	 * @inheritDoc
	 */
	public function init () : void {
		changeWatcher = BindingUtils.bindSetter(propertyChanged, target, propertyName);
	}
	
	private function propertyChanged (value:*) : void {
		_currentValue = value;
		publish(value);
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose () : void {
		changeWatcher.unwatch();
		changeWatcher = null;
		enabled = false;
		publish(null);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get currentValue () : * {
		return _currentValue;
	}
	
	
}
}