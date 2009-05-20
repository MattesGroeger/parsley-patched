package org.spicefactory.parsley.core.messaging {
import org.spicefactory.lib.errors.IllegalArgumentError;

/**
 * @author Jens Halm
 */
public class TestMessageHandlers {

	
	private var _test1Count:int = 0;
	private var _test2Count:int = 0;
	
	private var _sum:int = 0;
	
	
	public function get test1Count () : int {
		return _test1Count;
	}
	
	public function get test2Count () : int {
		return _test2Count;
	}
	
	public function get sum ():int {
		return _sum;
	}
	

	[MessageHandler]
	public function allTestMessages (message:TestMessage) : void {
		trace("AA");
		if (message.name == TestEvent.TEST1) {
			_test1Count++;
		}
		else if (message.name == TestEvent.TEST2) {
			_test2Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + message.name);
		}
		_sum += message.value;
	}

	[MessageHandler(selector="test1")]
	public function event1 (message:TestMessage) : void {
		trace("BB");
		if (message.name == TestEvent.TEST1) {
			_test1Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + message.name);
		}
		_sum += message.value;
	}
	
	[MessageHandler(selector="test2")]
	public function event2 (message:TestMessage) : void {
		trace("CC");
		if (message.name == TestEvent.TEST2) {
			_test2Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + message.name);
		}
		_sum += message.value;
	}
	

}
}
