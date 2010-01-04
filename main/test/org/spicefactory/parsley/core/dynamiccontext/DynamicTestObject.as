package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.parsley.util.MessageReceiverBase;

/**
 * @author Jens Halm
 */
public class DynamicTestObject extends MessageReceiverBase {
	
	public var dependency:DynamicTestDependency;
	
	public function handleMessage (message:Object) : void {
		addMessage(message);
	}
	
}
}
