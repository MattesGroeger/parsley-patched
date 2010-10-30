package org.spicefactory.parsley.command.mock {

/**
 * @author Jens Halm
 */
public class MockResult {
	
	public var value:String;
	public var error:Boolean;
	
	function MockResult (value:String, error:Boolean = false) {
		this.value = value;
		this.error = error;
	}
}
}
