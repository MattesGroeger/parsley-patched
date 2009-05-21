package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.core.messaging.TestMessage;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.EventSource;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageBindings;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageHandlers;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageInterceptors;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.TestMessageDispatcher;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.TestMessageHandlers;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class MessagingXmlTagTest extends XmlContextTestBase {
	
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="eventSource" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.EventSource" lazy="true">
			<managed-events names="test1,test2,foo"/>
		</object> 
		
		<object id="testDispatcher" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.TestMessageDispatcher" lazy="true">
			<message-dispatcher property="dispatcher"/>
		</object> 
	
		<object id="testMessageHandlers" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.TestMessageHandlers" lazy="true">
			<message-handler method="allTestMessages" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
			<message-handler method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
			<message-handler method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
		</object> 
	
		<object id="messageHandlers" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageHandlers" lazy="true">
			<message-handler method="allTestEvents" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-handler method="allEvents" type="flash.events.Event"/>
			<message-handler method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-handler method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-handler method="mappedProperties" message-properties="stringProp,intProp" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</object> 
	
		<object id="messageBindings" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageBindings" lazy="true">
			<message-binding target-property="stringProp" message-property="stringProp" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-binding target-property="intProp1" message-property="intProp" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-binding target-property="intProp2" message-property="intProp" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</object> 
	
		<object id="messageInterceptors" type="org.spicefactory.parsley.flex.mxmlconfig.messaging.MessageInterceptors" lazy="true">
			<message-interceptor method="interceptAllMessages" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-interceptor method="allEvents"/>
			<message-interceptor method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-interceptor method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</object> 	
	</objects>;

	
	public function testMessageHandlers () : void {
		var context:Context = getContext(config);
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
	
	public function testMessageBindings () : void {
		var context:Context = getContext(config);
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
		var context:Context = getContext(config);
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
		var context:Context = getContext(config);
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
