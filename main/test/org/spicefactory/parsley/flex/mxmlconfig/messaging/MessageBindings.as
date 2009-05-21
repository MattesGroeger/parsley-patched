package org.spicefactory.parsley.flex.mxmlconfig.messaging {

/**
 * @author Jens Halm
 */
public class MessageBindings {

	
	private var _stringProp:String = "";
	
	
	public function get stringProp ():String {
		return _stringProp;
	}
	
	public function set stringProp (value:String) : void {
		_stringProp += value;
	}
	
	public var intProp1:int;
	
	public var intProp2:int;

	
}
}
