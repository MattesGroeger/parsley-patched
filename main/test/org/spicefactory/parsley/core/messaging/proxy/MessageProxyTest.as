package org.spicefactory.parsley.core.messaging.proxy {
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
	
	
}
}
