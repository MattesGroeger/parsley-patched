package org.spicefactory.parsley.core.messaging {
import org.spicefactory.parsley.core.messaging.model.EventSourceMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageBindingsMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageHandlersMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageInterceptorsMetadata;
import org.spicefactory.parsley.core.messaging.model.TestMessageDispatcherMetadata;
import org.spicefactory.parsley.core.messaging.model.TestMessageHandlersMetadata;

/**
 * @author Jens Halm
 */
public class MessagingTestContainer {
	

	public function get eventSource () : EventSourceMetadata {
		return new EventSourceMetadata();
	}
	
	public function get testDispatcher () : TestMessageDispatcherMetadata {
		return new TestMessageDispatcherMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get testMessageHandlers () : TestMessageHandlersMetadata {
		return new TestMessageHandlersMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageHandlers () : MessageHandlersMetadata {
		return new MessageHandlersMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageBindings () : MessageBindingsMetadata {
		return new MessageBindingsMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageInterceptors () : MessageInterceptorsMetadata {
		return new MessageInterceptorsMetadata();
	}
	
	
}
}
