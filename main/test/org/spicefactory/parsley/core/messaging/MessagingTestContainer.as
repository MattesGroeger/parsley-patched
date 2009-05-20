package org.spicefactory.parsley.core.messaging {

/**
 * @author Jens Halm
 */
public class MessagingTestContainer {
	

	public function get eventSource () : EventSource {
		return new EventSource();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get messageHandlers () : MessageHandlers {
		return new MessageHandlers();
	}
	
	
}
}
