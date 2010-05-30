package org.spicefactory.parsley.flex.rpc {
import flexunit.framework.TestCase;

import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.flex.FlexConfig;

import mx.collections.ArrayCollection;
import mx.rpc.events.ResultEvent;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * @author Jens Halm
 */
public class AsyncTokenCommandTest extends TestCase {
	
	
	private var observer:ServiceObserver;
	
	
	public function testWithResult () : void {
		GlobalFactoryRegistry.instance.messageRouter.unhandledError = ErrorPolicy.RETHROW;
		
		var executor:ServiceExecutor = new ServiceExecutor();
		observer = new ServiceObserver();
		
		var context:Context = ContextBuilder.newBuilder()
				.config(FlexConfig.forClass(AsyncTokenTestConfig))
				.object(executor)
				.object(observer)
				.build();
		
		assertEquals("Unexpected number of objects in Context", 3, context.getObjectCount());
		
		var callback:Function = addAsync(onResultEvent, 3000);
		
		var timer:Timer = new Timer(500, 1);
		timer.addEventListener(TimerEvent.TIMER, callback);
		timer.start();
    			
		context.scopeManager.dispatchMessage(new TestEvent("test1", "The result", 0));
	}
	
	private function onResultEvent (event:Event) : void {
		assertNotNull("Expected ArrayCollection result instance", observer.result);
		assertTrue("Unexpected result type", (observer.result is ArrayCollection));
		assertTrue("Unexpected result event type", (observer.response is ResultEvent));
	}
	
	
}
}
