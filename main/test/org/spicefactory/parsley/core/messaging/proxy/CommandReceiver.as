package org.spicefactory.parsley.core.messaging.proxy {
import org.spicefactory.parsley.util.MessageCounter;

/**
 * @author Jens Halm
 */
public class CommandReceiver extends MessageCounter {
	
	
	public static var instanceCount:int = 0;
	
	function CommandReceiver () {
		instanceCount++;
	}
	
	[Command]
	public function handleMessage (message:Object) : void {
		addMessage(message);
	}
	
	
}
}
