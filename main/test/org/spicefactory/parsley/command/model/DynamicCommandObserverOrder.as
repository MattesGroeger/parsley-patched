package org.spicefactory.parsley.command.model {
import org.spicefactory.parsley.command.mock.MockResult;

/**
 * @author Jens Halm
 */
public class DynamicCommandObserverOrder {

	
	public static var order:OrderBuilder;
	
	
	public function execute (message:Object) : MockResult {
		order.add("-EXE");
		return new MockResult("foo");
	}
	
	public function result (resultValue:String, message:Object) : void {
		order.add("-DYN");
	}
	
	
}
}
