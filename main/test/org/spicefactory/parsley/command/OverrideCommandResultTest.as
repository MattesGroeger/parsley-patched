package org.spicefactory.parsley.command {
import org.hamcrest.object.equalTo;
import org.hamcrest.assertThat;
import org.spicefactory.parsley.messaging.messages.TestEvent;
import org.spicefactory.parsley.command.model.CommandExecutors;
import org.spicefactory.parsley.command.model.CommandExecutorsMetadata;
import org.spicefactory.parsley.command.model.OverrideCommandResultModel;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.dsl.context.ContextBuilder;

/**
 * @author Jens Halm
 */
public class OverrideCommandResultTest {
	
	
	[Test]
	public function overrideResult () : void {
		if (!CommandTestBase.factory) {
			CommandTestBase.registerMockCommandFactory();
		}
		CommandTestBase.factory.reset();
		
		var executors:CommandExecutors = new CommandExecutorsMetadata();
		var model:OverrideCommandResultModel = new OverrideCommandResultModel();
		var context:Context = ContextBuilder.newBuilder().object(executors).object(model).build();
		context.scopeManager.dispatchMessage(new TestEvent(TestEvent.TEST2, "foo", 0));
		CommandTestBase.factory.dispatchAll();
		assertThat(model.invocationOrder, equalTo("ABC"));
	}
	
	
}
}
