package org.spicefactory.parsley.command.model {

/**
 * @author Jens Halm
 */
public class OrderBuilder {
	
	private var _value:String = "";
	
	public function add (value:String) : void {
		_value += value;
	}
	
	public function get value () : String {
		return _value;
	}
	
}
}
