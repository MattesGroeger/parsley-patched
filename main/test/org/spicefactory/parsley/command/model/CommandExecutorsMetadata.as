package org.spicefactory.parsley.command.model {
import org.spicefactory.parsley.command.mock.MockResult;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandExecutorsMetadata extends CommandExecutors {
	
	
	[Command(type="org.spicefactory.parsley.messaging.messages.TestEvent", selector="test1")]
	public override function event1 (event:TestEvent) : MockResult {
		return new MockResult("foo1");
	}
	
	[Command(type="org.spicefactory.parsley.messaging.messages.TestEvent", selector="test2")]
	public override function event2 (event:TestEvent) : MockResult {
		return new MockResult("foo2");
	}
	
	[Command(type="org.spicefactory.parsley.messaging.messages.TestEvent", selector="test1")]
	public override function faultyCommand (event:TestEvent) : MockResult {
		return new MockResult("fault", true);
	}
	
	
}
}
