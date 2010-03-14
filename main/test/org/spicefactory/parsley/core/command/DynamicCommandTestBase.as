package org.spicefactory.parsley.core.command {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.command.model.DynamicCommand;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.core.scope.ScopeManager;

/**
 * @author Jens Halm
 */
public class DynamicCommandTestBase extends ContextTestBase {
	
	
	private var context:Context;
	
	
	
	public override function setUp () : void {
		CommandTestBase.init();
		CommandTestBase.factory.reset();
		DynamicCommand.instances = new Array();
		context = commandContext;
		checkState(context);
	}
	
	public function testStatelessWithResultHandler () : void {
		var sm:ScopeManager = context.scopeManager;
		assertEquals("Unexpected number of command instances", 0, DynamicCommand.instances.length);
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command1", "str", 0));
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		
		sm.dispatchMessage(new TestEvent("command1", "str", 0));
		assertEquals("Unexpected number of command instances", 2, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 2, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 1);
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 1, 1);
		
		CommandTestBase.factory.dispatchAll();
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 2, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 1, "foo1");
		validateCommand(DynamicCommand.instances[1] as DynamicCommand, 1, 1, "foo1");
	}
	
	public function testStatefulWithErrorHandler () : void {
		var sm:ScopeManager = context.scopeManager;
		assertEquals("Unexpected number of command instances", 0, DynamicCommand.instances.length);
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command2", "error", 0));
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1);
		
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1);
		
		sm.dispatchMessage(new TestEvent("command2", "error", 0));
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 2);
		
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 2, 2);
		
		CommandTestBase.factory.dispatchAll();
		sm.dispatchMessage("some message");
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 3, 2, "none", "foo2");
	}
	
	public function testDecorators () : void {
		var sm:ScopeManager = context.scopeManager;
		assertEquals("Unexpected number of command instances", 0, DynamicCommand.instances.length);
		
		sm.dispatchMessage("some message");
		sm.dispatchMessage(new TestEvent("command3", "foo", 0));
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 0, 1, "none", "none", 9);
		
		sm.dispatchMessage("some message");
		CommandTestBase.factory.dispatchAll();
		assertEquals("Unexpected number of command instances", 1, DynamicCommand.instances.length);
		validateCommand(DynamicCommand.instances[0] as DynamicCommand, 1, 1, "foo1", "none", 9, 1);
	}
	
	public function testDestroy () : void {
		context.destroy();
	}


	private function validateCommand (command:DynamicCommand, handlers:int, commands:int, 
			result:String = "none", error:String = "none", prop:int = 0, destroys:int = 0) : void {
		assertEquals("Unexpected count for message handlers", handlers, command.handlerCount);
		assertEquals("Unexpected count for command executions", commands, command.commandCount);
		assertEquals("Unexpected result value", result, command.resultValue);
		assertEquals("Unexpected error value", error, command.errorValue);
		assertEquals("Unexpected property value", prop, command.prop);
		assertEquals("Unexpected number of destroy method invocations", destroys, command.destroyCount);
	}

	
	public function get commandContext () : Context {
		throw new AbstractMethodError();
	}
	
	
}
}
