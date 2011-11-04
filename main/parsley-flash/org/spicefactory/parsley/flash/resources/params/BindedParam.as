package org.spicefactory.parsley.flash.resources.params {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.flash.resources.params.Param;

public class BindedParam implements Param {
	private var _instance:Object;
	private var _property:Property;

	public function BindedParam (instance:Object, property:Property) {
		_instance = instance;
		_property = property;
	}

	public function get value ():String {
		return _property.getValue(_instance);
	}
}
}
