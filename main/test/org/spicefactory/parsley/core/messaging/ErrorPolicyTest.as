package org.spicefactory.parsley.core.messaging {
import flexunit.framework.TestCase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.model.ErrorPolicyHandlers;
import org.spicefactory.parsley.dsl.context.ContextBuilder;

/**
 * @author Jens Halm
 */
public class ErrorPolicyTest extends TestCase {
	
	
	public function testErrorPolicyRethrow () : void {
		var handlers:ErrorPolicyHandlers = new ErrorPolicyHandlers();
		var context:Context = ContextBuilder
			.newSetup()
				.messageSettings(true)
					.unhandledError(ErrorPolicy.RETHROW)
			.newBuilder()
				.object(handlers)
				.build();
		try {
			context.scopeManager.dispatchMessage(new TestMessage());
		}
		catch (e:Error) {
			assertEquals("Unexpected number of handler invocations", 1, handlers.messageCount);
			return;
		}
		fail("Expected message error to be rethrown");
	}
	
	public function testErrorPolicyIgnore () : void {
		var handlers:ErrorPolicyHandlers = new ErrorPolicyHandlers();
		var context:Context = ContextBuilder
			.newSetup()
				.messageSettings(true)
					.unhandledError(ErrorPolicy.IGNORE)
			.newBuilder()
				.object(handlers)
				.build();
		context.scopeManager.dispatchMessage(new TestMessage());
		assertEquals("Unexpected number of handler invocations", 2, handlers.messageCount);
	}
	
	public function testErrorPolicyAbort () : void {
		var handlers:ErrorPolicyHandlers = new ErrorPolicyHandlers();
		var context:Context = ContextBuilder
			.newSetup()
				.messageSettings(true)
					.unhandledError(ErrorPolicy.ABORT)
			.newBuilder()
				.object(handlers)
				.build();
		context.scopeManager.dispatchMessage(new TestMessage());
		assertEquals("Unexpected number of handler invocations", 1, handlers.messageCount);
	}
	
	public function testErrorPolicyDefault () : void {
		/* default currently is ErrorPolicy.IGNORE */
		var handlers:ErrorPolicyHandlers = new ErrorPolicyHandlers();
		var context:Context = ContextBuilder
			.newBuilder()
				.object(handlers)
				.build();
		context.scopeManager.dispatchMessage(new TestMessage());
		assertEquals("Unexpected number of handler invocations", 2, handlers.messageCount);
	}
	
	
}
}
