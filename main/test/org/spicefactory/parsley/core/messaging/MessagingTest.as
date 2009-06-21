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
	
	public function testProxyMessageHandlers () : void {
		ProxyMessageHandlers.reset();
		var context:Context = ActionScriptContextBuilder.build(MessagingTestContainer);
		checkState(context);
		checkObjectIds(context, ["eventSource"], EventSource);	
		checkObjectIds(context, ["proxyMessageHandlers"], ProxyMessageHandlers);	
		var source:EventSource
				= getAndCheckObject(context, "eventSource", EventSource) as EventSource;
		source.dispatchEvent(new TestEvent(TestEvent.TEST1, "foo1", 7));
		source.dispatchEvent(new TestEvent(TestEvent.TEST2, "foo2", 9));
		source.dispatchEvent(new Event("foo"));
		assertEquals("Unexpected count for event test1", 2, ProxyMessageHandlers.test1Count);
		assertEquals("Unexpected count for event test2", 2, ProxyMessageHandlers.test2Count);
		assertEquals("Unexpected count for generic event handler", 3, ProxyMessageHandlers.genericEventCount);
		assertEquals("Unexpected instance count", 7, ProxyMessageHandlers.instanceCount);
	}
	
	public function testMessageBindings () : void {
		var context:Context = ActionScriptContextBuilder.build(MessagingTestContainer);
		checkState(context);
		checkObjectIds(context, ["eventSource"], EventSource);	
		checkObjectIds(context, ["messageBindings"], MessageBindings);	
		var source:EventSource
				= getAndCheckObject(context, "eventSource", EventSource) as EventSource;
		var bindings:MessageBindings 
				= getAndCheckObject(context, "messageBindings", MessageBindings) as MessageBindings;
		source.dispatchEvent(new TestEvent(TestEvent.TEST1, "foo1", 7));
		source.dispatchEvent(new TestEvent(TestEvent.TEST2, "foo2", 9));
		assertEquals("Unexpected value for string property", "foo1foo2", bindings.stringProp);
		assertEquals("Unexpected value for int1 property", 7, bindings.intProp1);
		assertEquals("Unexpected value for int2 property", 9, bindings.intProp2);
	}
	
	public function testMessageInterceptors () : void {
		var context:Context = ActionScriptContextBuilder.build(MessagingTestContainer);
		checkState(context);
		checkObjectIds(context, ["eventSource"], EventSource);	
		checkObjectIds(context, ["messageHandlers"], MessageHandlers);	
		checkObjectIds(context, ["messageInterceptors"], MessageInterceptors);	
		var source:EventSource
				= getAndCheckObject(context, "eventSource", EventSource) as EventSource;
		var handlers:MessageHandlers 
				= getAndCheckObject(context, "messageHandlers", MessageHandlers) as MessageHandlers;
		var interceptors:MessageInterceptors
				= getAndCheckObject(context, "messageInterceptors", MessageInterceptors) as MessageInterceptors;
				
		source.dispatchEvent(new TestEvent(TestEvent.TEST1, "foo1", 7));
		source.dispatchEvent(new TestEvent(TestEvent.TEST2, "foo2", 9));
		source.dispatchEvent(new Event("foo"));
		
		assertEquals("Unexpected count for event test1", 2, handlers.test1Count);
		assertEquals("Unexpected count for event test2", 0, handlers.test2Count);
		assertEquals("Unexpected count for generic event handler", 2, handlers.genericEventCount);
		assertEquals("Unexpected string property", "foo1", handlers.stringProp);
		assertEquals("Unexpected int property", 7, handlers.intProp);
		
		assertEquals("Unexpected count for event test1", 2, interceptors.test1Count);
		assertEquals("Unexpected count for event test2", 1, interceptors.test2Count);
		assertEquals("Unexpected count for generic event handler", 2, interceptors.genericEventCount);
		
		interceptors.proceedEvent2();
		
		assertEquals("Unexpected count for event test1", 2, handlers.test1Count);
		assertEquals("Unexpected count for event test2", 2, handlers.test2Count);
		assertEquals("Unexpected count for generic event handler", 3, handlers.genericEventCount);
		assertEquals("Unexpected string property", "foo2", handlers.stringProp);
		assertEquals("Unexpected int property", 9, handlers.intProp);
		
		assertEquals("Unexpected count for event test1", 2, interceptors.test1Count);
		assertEquals("Unexpected count for event test2", 2, interceptors.test2Count);
		assertEquals("Unexpected count for generic event handler", 3, interceptors.genericEventCount);		
	}
	
	public function testMessageDispatcher () : void {
		var context:Context = ActionScriptContextBuilder.build(MessagingTestContainer);
		checkState(context);
		checkObjectIds(context, ["testDispatcher"], TestMessageDispatcher);	
		checkObjectIds(context, ["testMessageHandlers"], TestMessageHandlers);	
		var dispatcher:TestMessageDispatcher
				= getAndCheckObject(context, "testDispatcher", TestMessageDispatcher) as TestMessageDispatcher;
		var handlers:TestMessageHandlers 
				= getAndCheckObject(context, "testMessageHandlers", TestMessageHandlers) as TestMessageHandlers;
		var m1:TestMessage = new TestMessage();
		m1.name = TestEvent.TEST1;
		m1.value = 3;
		dispatcher.dispatchMessage(m1);
		var m2:TestMessage = new TestMessage();
		m2.name = TestEvent.TEST2;
		m2.value = 5;
		dispatcher.dispatchMessage(m2);
		assertEquals("Unexpected count for event test1", 2, handlers.test1Count);
		assertEquals("Unexpected count for event test2", 2, handlers.test2Count);
		assertEquals("Unexpected sum value", 16, handlers.sum);
	}
	
	
}
}
