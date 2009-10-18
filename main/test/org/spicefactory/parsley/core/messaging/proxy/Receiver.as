package org.spicefactory.parsley.core.messaging.proxy {
import org.spicefactory.parsley.util.MessageCounter;

/**
 * @author Jens Halm
 */
public class Receiver extends MessageCounter {
	
	
	public static var instanceCount:int = 0;
	
	function Receiver () {
		trace("Receiver constructor");
		instanceCount++;
	}
	
	[MessageHandler]
	public function handleMessage (message:Object) : void {
		trace("got message");
		addMessage(message);
	}
	
	
}
}
