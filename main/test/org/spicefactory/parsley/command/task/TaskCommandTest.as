package org.spicefactory.parsley.command.task {
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;
import org.spicefactory.parsley.command.task.config.DynamicTaskCommandConfig;
import org.spicefactory.parsley.command.task.model.MockResultTask;
import org.spicefactory.parsley.command.task.model.TaskCommand;
import org.spicefactory.parsley.command.task.model.TaskExecutor;
import org.spicefactory.parsley.command.task.model.TaskObserver;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.FlexContextBuilder;
import org.spicefactory.parsley.messaging.messages.TestEvent;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.task.command.TaskCommandSupport;

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * @author Jens Halm
 */
public class TaskCommandTest {
	
	
	
	[Test]
	public function taskWithResult () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		context.scopeManager.dispatchMessage(new TestEvent("test1", "The result", 0));
		var task:MockResultTask = executor.lastTask;
		assertThat(task, notNullValue());
		task.finishWithResult();
		assertThat(observer.resultTask, notNullValue());
		assertThat(observer.resultEvent, notNullValue());
		assertThat(observer.resultString, equalTo("The result"));
	}
	
	[Test]
	public function taskWithError () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		context.scopeManager.dispatchMessage(new TestEvent("test2", "The error", 0));
		var task:MockResultTask = executor.lastTask;
		assertThat(task, notNullValue());
		task.finishWithError();
		assertThat(observer.errorEvent, notNullValue());
		assertThat(observer.errorEvent.text, equalTo("The error"));
	}
	
	[Test]
	public function restartableTask () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		executor.keepTask = true;
		var observer:TaskObserver = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		
		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		var task:MockResultTask = executor.lastTask;
		assertThat(task, notNullValue());
		task.finishWithResult();
		assertThat(observer.resultTask, notNullValue());
		assertThat(observer.resultEvent, notNullValue());
		assertThat(observer.resultString, equalTo("foo"));
		
		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		task = executor.lastTask;
		assertThat(task, notNullValue());
		task.finishWithResult();
		assertThat(observer.resultTask, notNullValue());
		assertThat(observer.resultEvent, notNullValue());
		assertThat(observer.resultString, equalTo("foo"));
	}
	
	private var observer:TaskObserver;
	
	[Test(async)]
	public function synchronousTask () : void {
		TaskCommandSupport.initialize();
		var executor:TaskExecutor = new TaskExecutor();
		observer = new TaskObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		
		context.scopeManager.dispatchMessage(new TestEvent("test3", "foo", 0));
		var task:MockResultTask = executor.lastTask;
		assertThat(task, notNullValue());
		var timer:Timer = new Timer(10, 1);
		var f:Function = Async.asyncHandler(this, synchronousTaskResult, 100);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();
	}
	
	private function synchronousTaskResult (event:TimerEvent, data:Object = null) : void {	
		assertThat(observer.resultString, equalTo("foo"));
		assertThat(observer.resultCounter, equalTo(1));
	}
	
	[Test(async)]
	public function synchronousDynamicCommand () : void {
		TaskCommandSupport.initialize();
		var context:Context = FlexContextBuilder.build(DynamicTaskCommandConfig);
		context.scopeManager.dispatchMessage(new TestEvent("test3", "foo", 0));
		assertThat(TaskCommand.lastTask, notNullValue());
		var timer:Timer = new Timer(10, 1);
		var f:Function = Async.asyncHandler(this, synchronousDynamicCommandResult, 100);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();		
	}
	
	private function synchronousDynamicCommandResult (event:TimerEvent, data:Object = null) : void {	
		assertThat(TaskCommand.resultString, equalTo("foo"));
		assertThat(TaskCommand.resultCounter, equalTo(1));
	}
	
	
}
}
