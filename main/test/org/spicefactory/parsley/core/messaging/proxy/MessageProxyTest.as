package org.spicefactory.parsley.core.messaging.proxy {
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import flexunit.framework.TestCase;

import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class MessageProxyTest extends TestCase {
	
	
	public function testMessageHandlerProxy () : void {
		MessageHandlerReceiver.instanceCount = 0;
		var context:Context = ActionScriptContextBuilder.build(MessageProxyConfig);
		var receiver:MessageHandlerReceiver = context.getObjectByType(MessageHandlerReceiver) as MessageHandlerReceiver;
		assertEquals("Unexpected number of messages", 1, receiver.getCount());
	}
	
	public function testCommandProxy () : void {
		MessageHandlerReceiver.instanceCount = 0;
		var context:Context = ActionScriptContextBuilder.build(MessageProxyConfig);
		var receiver:CommandReceiver = context.getObjectByType(CommandReceiver) as CommandReceiver;
		assertEquals("Unexpected number of messages", 1, receiver.getCount());
	}
	
	public function testRemoveProxyOnContextError () : void {
		var parent:Context = RuntimeContextBuilder.build([]);
		try {
			ActionScriptContextBuilder.build(FaultyObjectConfig, null, parent);
		}
		catch (e:Error) {
			/* expected error */
			var errorHandler:ErrorHandler = new ErrorHandler();
			var context:Context = RuntimeContextBuilder.build([errorHandler], null, parent);
			context.scopeManager.dispatchMessage(new Object());
			assertEquals("Unexpected error", 0, errorHandler.getCount());
			return;
		}
		fail("Expected error in ContextBuilder");
	}
	
	
}
}
