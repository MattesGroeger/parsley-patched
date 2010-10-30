package org.spicefactory.parsley.command {
import org.flexunit.assertThat;
import org.hamcrest.collection.arrayWithSize;
import org.hamcrest.object.equalTo;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.command.model.DynamicCommand;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class DynamicCommandTestBase {
	
	
	private var context:Context;
	
	
	[Before]
	public function setUp () : void {
		CommandTestBase.factory.reset();
		DynamicCommand.instances = new Array();
		context = commandContext;
	}
	
	[Test]
	public function statelessWithResultHandler () : void {
		var sm:ScopeManager = context.scopeManager;
		assertThat(DynamicCommand.instances, arrayWithSize(0));
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command1", "str", 0));
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		
		sm.dispatchMessage(new TestEvent("command1", "str", 0));
		assertThat(DynamicCommand.instances, arrayWithSize(2));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(2));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 1);
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 1, 1);
		
		CommandTestBase.factory.dispatchAll();
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(2));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 1, "foo1");
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 1, 1, "foo1");
	}
	
	[Test]
	public function statefulWithErrorHandler () : void {
		var sm:ScopeManager = context.scopeManager;
		assertThat(DynamicCommand.instances, arrayWithSize(0));
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command2", "error", 0));
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		
		sm.dispatchMessage(new TestEvent("command2", "error", 0));
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 2);
		
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 2);
		
		CommandTestBase.factory.dispatchAll();
		sm.dispatchMessage("some message");
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 3, 2, "none", "foo2");
	}
	
	[Test]
	public function decorators () : void {
		var sm:ScopeManager = context.scopeManager;
		assertThat(DynamicCommand.instances, arrayWithSize(0));
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command3", "foo", 0));
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1, "none", "none", 9);
		
		sm.dispatchMessage("some message");
		CommandTestBase.factory.dispatchAll();
		assertThat(DynamicCommand.instances, arrayWithSize(1));
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1, "foo1", "none", 9, 1);
	}
	

	private function validateCommand (command:DynamicCommand, handlers:int, commands:int, 
			result:String = "none", error:String = "none", prop:int = 0, destroys:int = 0) : void {
		assertThat(command.handlerCount, equalTo(handlers));
		assertThat(command.commandCount, equalTo(commands));
		assertThat(command.resultValue, equalTo(result));
		assertThat(command.errorValue, equalTo(error));
		assertThat(command.prop, equalTo(prop));
		assertThat(command.destroyCount, equalTo(destroys));
	}

	
	public function get commandContext () : Context {
		throw new AbstractMethodError();
	}
	
	
}
}
