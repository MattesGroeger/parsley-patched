package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.MessagingTestBase;

/**
 * @author Jens Halm
 */
public class MessagingXmlTagTest extends MessagingTestBase {
	
	
	function MessagingXmlTagTest () {
		super(true);
	}
	
	public override function get messagingContext () : Context {
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="eventSource" type="org.spicefactory.parsley.core.messaging.model.EventSource" lazy="true">
			<managed-events names="test1, test2, foo"/>
		</object> 
		
		<object id="eventSource2" type="org.spicefactory.parsley.core.messaging.model.EventSource" singleton="false">
			<managed-events names="test1, test2, foo"/>
		</object> 
		
		<dynamic-object id="testDispatcher" type="org.spicefactory.parsley.core.messaging.model.TestMessageDispatcher">
			<message-dispatcher property="dispatcher"/>
		</dynamic-object> 
	
		<dynamic-object id="testMessageHandlers" type="org.spicefactory.parsley.core.messaging.model.TestMessageHandlers">
			<message-handler method="allTestMessages" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
			<message-handler method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
			<message-handler method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestMessage"/>
		</dynamic-object> 
		
		<dynamic-object id="messageHandlers" type="org.spicefactory.parsley.core.messaging.model.MessageHandlers">
			<message-handler method="allTestEvents" type="org.spicefactory.parsley.core.messaging.TestEvent" order="3"/>
			<message-handler method="allEvents" type="flash.events.Event" order="2"/>
			<message-handler method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent" order="1"/>
			<message-handler method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent" order="1"/>
			<message-handler method="mappedProperties" message-properties="stringProp,intProp" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</dynamic-object>
		
		<dynamic-object id="faultyHandlers" type="org.spicefactory.parsley.core.messaging.model.FaultyMessageHandlers">
			<message-handler method="allTestEvents" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-handler method="allEvents" type="flash.events.Event"/>
			<message-handler method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-handler method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</dynamic-object>
		
		<object id="errorHandlers" type="org.spicefactory.parsley.core.messaging.model.ErrorHandlers">
			<message-error method="allTestEvents" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-error method="allEvents" type="flash.events.Event"/>
			<message-error method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-error method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</object>
	
		<dynamic-object id="messageBindings" type="org.spicefactory.parsley.core.messaging.model.MessageBindingsBlank">
			<message-binding target-property="stringProp" message-property="stringProp" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-binding target-property="intProp1" message-property="intProp" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-binding target-property="intProp2" message-property="intProp" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
		</dynamic-object> 
	
		<dynamic-object id="messageInterceptors" type="org.spicefactory.parsley.core.messaging.model.MessageInterceptors">
			<message-interceptor method="interceptAllMessages" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<message-interceptor method="allEvents"/>
			<message-interceptor method="event1" selector="test1" type="org.spicefactory.parsley.core.messaging.TestEvent" order="1"/>
			<message-interceptor method="event2" selector="test2" type="org.spicefactory.parsley.core.messaging.TestEvent" order="1"/>
		</dynamic-object> 	
	</objects>;

	
}
}
