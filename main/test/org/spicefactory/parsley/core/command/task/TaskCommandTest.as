package org.spicefactory.parsley.core.command.task {
import flexunit.framework.TestCase;

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.flex.FlexContextBuilder;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.task.command.TaskCommandSupport;

import flash.events.TimerEvent;
import flash.utils.Timer;

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
	
	public function testRestartableTask () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		executor.keepTask = true;
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		
		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		var task:MockResultTask = executor.lastTask;
		assertNotNull("Expected ResultTask instance", task);
		task.finishWithResult();
		assertNotNull("Expected ResultTask instance", observer.resultTask);
		assertNotNull("Expected TaskEvent instance", observer.resultEvent);
		assertNotNull("Expected String result instance", observer.resultString);
		assertEquals("Unexpected result value", "foo", observer.resultString);
		
		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		task = executor.lastTask;
		assertNotNull("Expected ResultTask instance", task);
		task.finishWithResult();
		assertNotNull("Expected ResultTask instance", observer.resultTask);
		assertNotNull("Expected TaskEvent instance", observer.resultEvent);
		assertNotNull("Expected String result instance", observer.resultString);
		assertEquals("Unexpected result value", "foo", observer.resultString);
	}
	
	private var observer:TaskObserver;
	
	public function testSynchronousTask () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		observer = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		assertEquals("Unexpected number of objects in Context", 2, context.getObjectCount());
		
		context.scopeManager.dispatchMessage(new TestEvent("test3", "foo", 0));
		var task:MockResultTask = executor.lastTask;
		assertNotNull("Expected ResultTask instance", task);
		var timer:Timer = new Timer(10, 1);
		var f:Function = addAsync(synchronousTaskResult, 100);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();
	}
	
	private function synchronousTaskResult (event:TimerEvent) : void {	
		assertNotNull("Expected String result instance", observer.resultString);
		assertEquals("Unexpected result value", "foo", observer.resultString);
		assertEquals("Unexpected number of result invocations", 1, observer.resultCounter);
	}
	
	
	public function testSynchronousDynamicCommand () : void {
		TaskCommandSupport.initialize();
		var context:Context = FlexContextBuilder.build(DynamicTaskCommandConfig);
		
		context.scopeManager.dispatchMessage(new TestEvent("test3", "foo", 0));
		assertNotNull("Expected ResultTask instance", TaskCommand.lastTask);
		var timer:Timer = new Timer(10, 1);
		var f:Function = addAsync(synchronousDynamicCommandResult, 100);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();		
	}
	
	private function synchronousDynamicCommandResult (event:TimerEvent) : void {	
		assertNotNull("Expected String result instance", TaskCommand.resultString);
		assertEquals("Unexpected result value", "foo", TaskCommand.resultString);
		assertEquals("Unexpected number of result invocations", 1, TaskCommand.resultCounter);
	}
	
	
	
	
}
}
