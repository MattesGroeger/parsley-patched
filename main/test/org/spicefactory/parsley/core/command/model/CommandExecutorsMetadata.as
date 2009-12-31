package org.spicefactory.parsley.core.command.model {
import org.spicefactory.parsley.core.command.mock.MockResult;
import org.spicefactory.parsley.core.messaging.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandExecutorsMetadata extends CommandExecutors {
	
	
	[Command(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]
	public override function event1 (event:TestEvent) : MockResult {
		return new MockResult("foo1");
	}
	
	[Command(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test2")]
	public override function event2 (event:TestEvent) : MockResult {
		return new MockResult("foo2");
	}
	
	[Command(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]
	public override function faultyCommand (event:TestEvent) : MockResult {
		return new MockResult("fault", true);
	}
	
	
}
}
