package org.spicefactory.parsley.core.command.task {
	import org.spicefactory.parsley.task.commands.TaskCommandSupport;
import flexunit.framework.TestCase;

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;

/**
 * @author Jens Halm
 */
public class TaskCommandTest extends TestCase {
	
	
	
	public function testTaskWithResult () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		assertEquals("Unexpected number of objects in Context", 2, context.getObjectCount());
		
		context.scopeManager.dispatchMessage(new TestEvent("test1", "The result", 0));
		var task:MockResultTask = executor.lastTask;
		assertNotNull("Expected ResultTask instance", task);
		task.finishWithResult();
		assertNotNull("Expected ResultTask instance", observer.resultTask);
		assertNotNull("Expected TaskEvent instance", observer.resultEvent);
		assertNotNull("Expected String result instance", observer.resultString);
		assertEquals("Unexpected result value", "The result", observer.resultString);
	}
	
	public function testTaskWithError () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		assertEquals("Unexpected number of objects in Context", 2, context.getObjectCount());
		
		context.scopeManager.dispatchMessage(new TestEvent("test2", "The error", 0));
		var task:MockResultTask = executor.lastTask;
		assertNotNull("Expected ResultTask instance", task);
		task.finishWithError();
		assertNotNull("Expected ErrorEvent instance", observer.errorEvent);
		assertEquals("Unexpected error message", "The error", observer.errorEvent.text);
	}

	
}
}
