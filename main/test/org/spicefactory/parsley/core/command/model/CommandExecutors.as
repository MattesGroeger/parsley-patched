package org.spicefactory.parsley.core.command.model {
import org.spicefactory.parsley.core.command.mock.MockResult;
import org.spicefactory.parsley.core.messaging.TestEvent;

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
