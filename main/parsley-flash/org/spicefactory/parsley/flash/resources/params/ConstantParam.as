package org.spicefactory.parsley.flash.resources.params {
import org.spicefactory.parsley.flash.resources.params.Param;

public class ConstantParam implements Param {
	private var _value:String;

	public function ConstantParam (value:String) {
		_value = value;
	}

	public function get value ():String {
		return _value;
	}
}
}
