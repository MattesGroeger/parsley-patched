package org.spicefactory.parsley.core.messaging {

/**
 * @author Jens Halm
 */
public class MessagingTestContainer {
	

	public function get eventSource () : EventSource {
		return new EventSource();
	}
	
	public function get testDispatcher () : TestMessageDispatcher {
		return new TestMessageDispatcher();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get testMessageHandlers () : TestMessageHandlers {
		return new TestMessageHandlers();
	}
	
	[ObjectDefinition(singleton="false")]
	public function get proxyMessageHandlers () : ProxyMessageHandlers {
		return new ProxyMessageHandlers();
	}
	
	
	[ObjectDefinition(lazy="true")]
	public function get messageHandlers () : MessageHandlers {
		return new MessageHandlers();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageBindings () : MessageBindings {
		return new MessageBindings();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageInterceptors () : MessageInterceptors {
		return new MessageInterceptors();
	}
	
	
}
}
