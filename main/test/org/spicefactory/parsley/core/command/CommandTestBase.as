package org.spicefactory.parsley.core.command {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.command.mock.MockCommandFactory;
import org.spicefactory.parsley.core.command.mock.MockResult;
import org.spicefactory.parsley.core.command.model.CommandExecutors;
import org.spicefactory.parsley.core.command.model.CommandObservers;
import org.spicefactory.parsley.core.command.model.CommandStatusFlags;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.messaging.model.EventSource;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.scope.ScopeName;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class CommandTestBase extends ContextTestBase {
	
	
	
	private static var factory:MockCommandFactory;
	
	
	private static function init () : void {
		if (factory == null) {
			factory = new MockCommandFactory();
			GlobalFactoryRegistry.instance.messageRouter.addCommandFactory(MockResult, factory);
		}
	}
	
	
	public function testCommandResult () : void {
		init();
		factory.reset();
		var context:Context = commandContext;
		checkState(context);
		checkObjectIds(context, ["commandExecutors"], CommandExecutors);	
		checkObjectIds(context, ["commandObservers"], CommandObservers);	
		context.getObjectByType(CommandExecutors) as EventSource;
		var observers:CommandObservers = context.getObjectByType(CommandObservers) as CommandObservers;
		var sm:ScopeManager = context.scopeManager;
		sm.dispatchMessage(new TestEvent(TestEvent.TEST1, "foo1", 7));
		sm.dispatchMessage(new TestEvent(TestEvent.TEST2, "foo2", 9));
		sm.dispatchMessage(new Event("foo"));
		factory.dispatchAll();
		
		assertEquals("Unexpected count for noParam", 1, observers.noParamCalled);
		assertEquals("Unexpected count for oneParamResult", 1, observers.oneParamResult.length);
		assertEquals("Unexpected count for twoParamsResult", 1, observers.twoParamsResult.length);
		assertEquals("Unexpected count for twoParamsMessage", 1, observers.twoParamsMessage.length);
		assertEquals("Unexpected count for errorResult", 1, observers.errorResult.length);
		assertEquals("Unexpected count for errorMessage", 1, observers.errorMessage.length);
		
		assertEquals("Unexpected value for oneParamResult", "foo1", observers.oneParamResult[0]);
		assertEquals("Unexpected value for twoParamsResult", "foo1", observers.twoParamsResult[0]);
		assertEquals("Unexpected value for twoParamsMessage", 7, TestEvent(observers.twoParamsMessage[0]).intProp);
		assertEquals("Unexpected value for errorResult", "fault", observers.errorResult[0]);
		assertEquals("Unexpected value for errorMessage", 7, TestEvent(observers.errorMessage[0]).intProp);
	}
	
	public function testCommandStatus () : void {
		init();
		factory.reset();
		var context:Context = commandContext;
		checkState(context);
		checkObjectIds(context, ["commandExecutors"], CommandExecutors);	
		checkObjectIds(context, ["commandStatusFlags"], CommandStatusFlags);	
		context.getObjectByType(CommandExecutors) as EventSource;
		var flags:CommandStatusFlags = context.getObjectByType(CommandStatusFlags) as CommandStatusFlags;
		var sm:ScopeManager = context.scopeManager;
		var cm:CommandManager = sm.getScope(ScopeName.GLOBAL).commandManager;
		
		validateFlags(flags, false, false, false);
		validateManager(cm, 0, 0, 0);
		
		sm.dispatchMessage(new TestEvent(TestEvent.TEST1, "foo1", 7));
		validateFlags(flags, true, true, false);
		validateManager(cm, 2, 2, 0);
		
		sm.dispatchMessage(new TestEvent(TestEvent.TEST2, "foo2", 9));
		validateFlags(flags, true, true, true);
		validateManager(cm, 3, 2, 1);
		
		sm.dispatchMessage(new Event("foo"));
		validateFlags(flags, true, true, true);
		validateManager(cm, 3, 2, 1);

		factory.getNextCommand().dispatchResult();
		validateFlags(flags, true, true, true);
		validateManager(cm, 2, 1, 1);

		factory.getNextCommand().dispatchResult();
		validateFlags(flags, true, false, true);
		validateManager(cm, 1, 0, 1);

		factory.getNextCommand().dispatchResult();
		validateFlags(flags, false, false, false);
		validateManager(cm, 0, 0, 0);
		
	}
	
	public function testStatusFlagInitValue () : void {
		init();
		factory.reset();
		var context:Context = commandContext;
		checkState(context);
		context.getObjectByType(CommandExecutors) as EventSource;
		var sm:ScopeManager = context.scopeManager;
		var cm:CommandManager = sm.getScope(ScopeName.GLOBAL).commandManager;
		
		validateManager(cm, 0, 0, 0);
		
		sm.dispatchMessage(new TestEvent(TestEvent.TEST1, "foo1", 7));
		var flags:CommandStatusFlags = context.getObjectByType(CommandStatusFlags) as CommandStatusFlags;
		validateFlags(flags, true, true, false);
		validateManager(cm, 2, 2, 0);
		factory.dispatchAll();
		validateFlags(flags, false, false, false);
		validateManager(cm, 0, 0, 0);
	}
	
	private var tempCnt:int = 0;
	
	private function validateFlags (flags:CommandStatusFlags, both:Boolean, flag1:Boolean, flag2:Boolean) : void {
		assertEquals("Unexpected value for command flag", both, flags.flag1and2); 
		assertEquals("Unexpected value for command flag", flag1, flags.flag1);
		assertEquals("Unexpected value for command flag", flag2, flags.flag2);
	}
	
	private function validateManager (cm:CommandManager, both:uint, flag1:uint, flag2:uint) : void {
		assertEquals("Unexpected number of active commands (without selector)", both, cm.getActiveCommands(TestEvent).length);
		assertEquals("Unexpected number of active commands (with selector test1)", flag1, cm.getActiveCommands(TestEvent, "test1").length);
		assertEquals("Unexpected number of active commands (with selector test2)", flag2, cm.getActiveCommands(TestEvent, "test2").length);
	}

	
	
	public function get commandContext () : Context {
		throw new AbstractMethodError();
	}
	
	
}
}
