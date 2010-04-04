package org.spicefactory.parsley.core.messaging {
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.core.messaging.model.MessageInterceptorsMetadata;
import org.spicefactory.parsley.core.messaging.model.MessageInterceptors;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class MessagingMetadataTagTest extends MessagingTestBase {
	

	function MessagingMetadataTagTest () {
		super(false);
	}
		
	public override function get messagingContext () : Context {
		return ActionScriptContextBuilder.build(MessagingTestConfig);
	}
	
	
	public function testInterceptorWithoutHandler () : void {
		var interceptors:MessageInterceptors = new MessageInterceptorsMetadata();
		var context:Context = RuntimeContextBuilder.build([interceptors]);
		context.scopeManager.dispatchMessage(new TestEvent(TestEvent.TEST1, "", 0));
		assertEquals("Unexpected interceptor invocation count", 2, interceptors.test1Count);
	}
	
	
}
}
