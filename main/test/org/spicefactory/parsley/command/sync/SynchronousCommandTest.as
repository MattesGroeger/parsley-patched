package org.spicefactory.parsley.command.sync {
import org.flexunit.async.Async;
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.nullValue;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.messaging.messages.TestEvent;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * @author Jens Halm
 */
public class SynchronousCommandTest {
	
	
	private var observer:CommandObserver;
	
	[Test(async)]
	public function testSynchronousTask () : void {
		var executor:CommandExecutor = new CommandExecutor();
		observer = new CommandObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
 		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		var timer:Timer = new Timer(100, 1);
		var f:Function = Async.asyncHandler(this, synchronousCommandResult, 1000);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();
	}
	
	private function synchronousCommandResult (event:TimerEvent, data:Object = null) : void {	
		assertThat(observer.result, nullValue());
		assertThat(observer.counter, equalTo(1));
	}
	
	
}
}
