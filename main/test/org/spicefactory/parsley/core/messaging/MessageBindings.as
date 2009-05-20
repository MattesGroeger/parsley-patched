package org.spicefactory.parsley.core.messaging {

/**
 * @author Jens Halm
 */
public class MessageBindings {

	
	private var _stringProp:String = "";
	
	
	public function get stringProp ():String {
		return _stringProp;
	}
	
	[MessageBinding(type="org.spicefactory.parsley.core.messaging.TestEvent", messageProperty="stringProp")]
	public function set stringProp (value:String) : void {
		_stringProp += value;
	}
	
	[MessageBinding(type="org.spicefactory.parsley.core.messaging.TestEvent", messageProperty="intProp", selector="test1")]
	public var intProp1:int;
	
	[MessageBinding(type="org.spicefactory.parsley.core.messaging.TestEvent", messageProperty="intProp", selector="test2")]
	public var intProp2:int;

	
}
}
