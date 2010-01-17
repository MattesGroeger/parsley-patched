package org.spicefactory.parsley.core.command.task {
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.messaging.TestEvent;

/**
 * @author Jens Halm
 */
public class TaskExecutor {
	
	
	public var lastTask:MockResultTask;
	
	
	
	[Command(selector="test1")]
	public function executeWithResult (event:TestEvent) : Task {
		lastTask = new MockResultTask(event.stringProp);
		return lastTask;
	}
	
	
	[Command(selector="test2")]
	public function executeWithError (event:TestEvent) : Task {
		lastTask = new MockResultTask(event.stringProp);
		return lastTask;
	}
	
	
	[Command(selector="test3")]
	public function synchronousTask (event:TestEvent) : Task {
		lastTask = new MockResultTask(event.stringProp, true);
		return lastTask;
	}
	
	
}
}
