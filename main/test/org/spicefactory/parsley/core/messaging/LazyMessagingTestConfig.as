package org.spicefactory.parsley.core.messaging {
import org.spicefactory.parsley.core.command.model.CommandExecutors;
import org.spicefactory.parsley.core.command.model.CommandObservers;
import org.spicefactory.parsley.core.messaging.model.ErrorHandlersMetadata;
import org.spicefactory.parsley.core.messaging.model.EventSourceMetadata;
import org.spicefactory.parsley.core.messaging.model.FaultyMessageHandlersMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageBindingsMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageHandlersMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageInterceptorsMetadata;
import org.spicefactory.parsley.core.messaging.model.TestMessageDispatcherMetadata;
import org.spicefactory.parsley.core.messaging.model.TestMessageHandlersMetadata;

/**
 * @author Jens Halm
 */
public class LazyMessagingTestConfig {
	

	public function get eventSource () : EventSourceMetadata {
		return new EventSourceMetadata();
	}
	
	[ObjectDefinition(singleton="false")]
	public function get eventSource2 () : EventSourceMetadata {
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
	public function get faultyHandlers () : FaultyMessageHandlersMetadata {
		return new FaultyMessageHandlersMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get commandExecutors () : CommandExecutors {
		return new CommandExecutors();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get commandObservers () : CommandObservers {
		return new CommandObservers();
	}
	
	
	public function get errorHandlers () : ErrorHandlersMetadata {
		return new ErrorHandlersMetadata();
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
