package org.spicefactory.parsley.command.task.model {
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class TaskExecutor {
	
	
	public var lastTask:MockResultTask;
	
	public var keepTask:Boolean = false;
	
	
	[Command(selector="test1")]
	public function executeWithResult (event:TestEvent) : Task {
		if (lastTask && keepTask) return lastTask;
		lastTask = new MockResultTask(event.stringProp, false, keepTask);
		return lastTask;
	}
	
	
	[Command(selector="test2")]
	public function executeWithError (event:TestEvent) : Task {
		if (lastTask && keepTask) return lastTask;
		lastTask = new MockResultTask(event.stringProp, false, keepTask);
		return lastTask;
	}
	
	
	[Command(selector="test3")]
	public function synchronousTask (event:TestEvent) : Task {
		if (lastTask && keepTask) return lastTask;
		lastTask = new MockResultTask(event.stringProp, true, keepTask);
		return lastTask;
	}
	
	
}
}
