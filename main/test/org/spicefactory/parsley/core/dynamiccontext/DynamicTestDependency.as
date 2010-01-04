package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.parsley.util.MessageReceiverBase;

/**
 * @author Jens Halm
 */
public class DynamicTestDependency extends MessageReceiverBase {
	
	public var destroyMethodCalled:Boolean = false;
	
	[Destroy]	
	public function destroy () : void {
		destroyMethodCalled = true;
	}
	
}
}
