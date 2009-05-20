package org.spicefactory.parsley.core.messaging {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class MessagingTest extends ContextTestBase {
	
	
	
	public function testMessageHandlers () : void {
		var context:Context = ActionScriptContextBuilder.build(MessagingTestContainer);
		checkState(context);
		checkObjectIds(context, ["eventSource"], EventSource);	
		checkObjectIds(context, ["messageHandlers"], MessageHandlers);	
		var source:EventSource
				= getAndCheckObject(context, "eventSource", EventSource) as EventSource;
		var handlers:MessageHandlers 
				= getAndCheckObject(context, "messageHandlers", MessageHandlers) as MessageHandlers;
		source.dispatchEvent(new TestEvent(TestEvent.TEST1, "foo1", 7));
		source.dispatchEvent(new TestEvent(TestEvent.TEST2, "foo2", 9));
		source.dispatchEvent(new Event("foo"));
		assertEquals("Unexpected count for event test1", 2, handlers.test1Count);
		assertEquals("Unexpected count for event test2", 2, handlers.test2Count);
		assertEquals("Unexpected count for generic event handler", 3, handlers.genericEventCount);
		assertEquals("Unexpected string property", "foo2", handlers.stringProp);
		assertEquals("Unexpected int property", 9, handlers.intProp);
	}
	
	
}
}
