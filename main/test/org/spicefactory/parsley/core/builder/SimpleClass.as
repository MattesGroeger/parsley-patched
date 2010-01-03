package org.spicefactory.parsley.core.builder {

/**
 * @author Jens Halm
 */
public class SimpleClass {
	
	
	public static var instanceCounter:int = 0;
	public var initCalled:Boolean;
	
	function SimpleClass () {
		instanceCounter++;
	}
	
	[Init]
	public function init () : void {
		trace("INIT!!!");
		initCalled = true;
	}
	
}
}
