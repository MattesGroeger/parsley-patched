package org.spicefactory.parsley.command {
import org.flexunit.assertThat;
import org.hamcrest.collection.array;
import org.hamcrest.collection.arrayWithSize;
import org.hamcrest.core.allOf;
import org.hamcrest.core.isA;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasProperty;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.command.mock.MockCommandFactory;
import org.spicefactory.parsley.command.mock.MockResult;
import org.spicefactory.parsley.command.model.CommandExecutors;
import org.spicefactory.parsley.command.model.CommandObservers;
import org.spicefactory.parsley.command.model.CommandStatusFlags;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.scope.ScopeManager;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.messaging.messages.TestEvent;
import org.spicefactory.parsley.messaging.model.EventSource;
import org.spicefactory.parsley.util.contextInState;
import org.spicefactory.parsley.util.contextWithIds;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class CommandTestBase {
	
	
	internal static var factory:MockCommandFactory;
	
	private var context:Context;
	
	
	[BeforeClass]
	public static function registerMockCommandFactory () : void {
		if (!factory) {
			factory = new MockCommandFactory();
			BootstrapDefaults.config.messageSettings.commandFactories.addCommandFactory(MockResult, factory);
		}
	}
	
	[Before]
	public function setUp () : void {
		factory.reset();
		context = commandContext;
	}
	
	
	[Test]
	public function contextState () : void {
		assertThat(context, contextInState());
		assertThat(context, contextWithIds(CommandExecutors, "commandExecutors"));
		assertThat(context, contextWithIds(CommandObservers, "commandObservers"));
		assertThat(context, contextWithIds(CommandStatusFlags, "commandStatusFlags"));
	}
	
	[Test]
	public function commandResult () : void {
		context.getObjectByType(CommandExecutors) as EventSource;
		var observers:CommandObservers = context.getObjectByType(CommandObservers) as CommandObservers;
		var sm:ScopeManager = context.scopeManager;
		sm.dispatchMessage(new TestEvent(TestEvent.TEST1, "foo1", 7));
		sm.dispatchMessage(new TestEvent(TestEvent.TEST2, "foo2", 9));
		sm.dispatchMessage(new Event("foo"));
		factory.dispatchAll();
		
		assertThat(observers.noParamCalled, equalTo(1));
		assertThat(observers.oneParamResult, array("foo1"));
		assertThat(observers.twoParamsResult, array("foo1"));
		assertThat(observers.twoParamsMessage, array(allOf(isA(TestEvent), hasProperty("intProp", 7))));
		assertThat(observers.errorResult, array("fault"));
		assertThat(observers.errorMessage, array(allOf(isA(TestEvent), hasProperty("intProp", 7))));
		assertThat(observers.completeInvoked, equalTo(1));
	}
	
	[Test]
	public function commandStatus () : void {
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
	
	[Test]
	public function statusFlagInitValue () : void {
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
	
	
	private function validateFlags (flags:CommandStatusFlags, both:Boolean, flag1:Boolean, flag2:Boolean) : void {
		assertThat(flags.flag1and2, equalTo(both));
		assertThat(flags.flag1, equalTo(flag1));
		assertThat(flags.flag2, equalTo(flag2));
	}
	
	private function validateManager (cm:CommandManager, both:uint, flag1:uint, flag2:uint) : void {
		assertThat(cm.getActiveCommands(TestEvent), arrayWithSize(both));
		assertThat(cm.getActiveCommands(TestEvent, "test1"), arrayWithSize(flag1));
		assertThat(cm.getActiveCommands(TestEvent, "test2"), arrayWithSize(flag2));
	}

	
	
	public function get commandContext () : Context {
		throw new AbstractMethodError();
	}
	
	
}
}
