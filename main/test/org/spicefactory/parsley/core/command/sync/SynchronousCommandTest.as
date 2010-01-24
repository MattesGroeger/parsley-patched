package org.spicefactory.parsley.core.command.sync {
import flexunit.framework.TestCase;

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * @author Jens Halm
 */
public class SynchronousCommandTest extends TestCase {
	
	
	private var observer:CommandObserver;
	
	public function testSynchronousTask () : void {
		var executor:CommandExecutor = new CommandExecutor();
		observer = new CommandObserver();
		var context:Context = RuntimeContextBuilder.build([executor, observer]);
		assertEquals("Unexpected number of objects in Context", 2, context.getObjectCount());
		
		trace("A " + observer.counter);
		context.scopeManager.dispatchMessage(new TestEvent("test1", "foo", 0));
		trace("B " + observer.counter);
		var timer:Timer = new Timer(10, 1);
		var f:Function = addAsync(synchronousCommandResult, 100);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();
	}
	
	private function synchronousCommandResult (event:TimerEvent) : void {	
		assertNull("Expected no result value", observer.result);
		assertEquals("Expected number of command result handler invocations", 1, observer.counter);
	}
}
}
