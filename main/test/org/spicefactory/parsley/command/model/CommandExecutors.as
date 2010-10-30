package org.spicefactory.parsley.command.model {
import org.spicefactory.parsley.command.mock.MockResult;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandExecutors {
	
	
	public function event1 (event:TestEvent) : MockResult {
		return new MockResult("foo1");
	}
	
	public function event2 (event:TestEvent) : MockResult {
		return new MockResult("foo2");
	}
	
	public function faultyCommand (event:TestEvent) : MockResult {
		return new MockResult("fault", true);
	}
	
	
}
}
