package org.spicefactory.parsley.core.messaging.proxy {

/**
 * @author Jens Halm
 */
public class FaultyObjectConfig {
	
	
	[ObjectDefinition(order="1")]
	public function get faultyObject () : FaultyObject {
		return new FaultyObject();
	}
	
	[ObjectDefinition(order="2")]
	public function get receiver () : MessageHandlerReceiver {
		return new MessageHandlerReceiver();
	}
	
	
}
}
