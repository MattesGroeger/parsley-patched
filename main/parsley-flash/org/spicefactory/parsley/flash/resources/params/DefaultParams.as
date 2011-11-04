package org.spicefactory.parsley.flash.resources.params {

import org.spicefactory.lib.reflect.Property;

import flash.utils.Dictionary;

public class DefaultParams implements Params {

	private var _params:Dictionary = new Dictionary();

	public function registerParamBinding (instance:Object, property:Property, key:String):void {
		_params[key] = new BindedParam(instance, property);
	}

	public function registerParam (key:String, value:String):void {
		_params[key] = new ConstantParam(value);
	}

	public function unregisterParam (key:String):void {
		_params[key] = null;
		delete _params[key];
	}

	public function hasParam (key:String):Boolean {
		return _params[key] != null;
	}

	public function getParam (key:String):String {
		return Param(_params[key]).value;
	}
}
}
