package org.spicefactory.parsley.config {
import org.hamcrest.assertThat;
import org.hamcrest.core.isA;
import org.hamcrest.core.not;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.sameInstance;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.coretag.inject.model.InjectedDependency;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.testmodel.SimpleInjectionTarget;

/**
 * @author Jens Halm
 */
public class DslConfigTest {
	
	
	[Test]
	public function messageRouterDelegate () : void {
		MessageRouterDecorator.initCount = 0;
		MessageRouterDecorator.messageCount = 0;
		var context:Context = ContextBuilder.newSetup()
				.services(true).messageRouter().addDecorator(MessageRouterDecorator)
				.newBuilder()
				.build();	
		context.scopeManager.dispatchMessage(Object);
		assertThat(MessageRouterDecorator.initCount, equalTo(4));
		assertThat(MessageRouterDecorator.messageCount, equalTo(1));
	}
	
	[Test]
	public function injectFromDefinition () : void {
		var builder:ContextBuilder = ContextBuilder.newBuilder();
		
		var target:ObjectDefinitionBuilder = builder.objectDefinition().forClass(SimpleInjectionTarget);
		var dependency:DynamicObjectDefinition = builder.objectDefinition()
			.forClass(InjectedDependency)
				.asDynamicObject()
					.build();
					
		target.constructorArgs().injectFromDefinition(dependency);
		target.property("fromProperty").injectFromDefinition(dependency);
		target.method("init").injectFromDefinition(dependency);
		
		target.asSingleton().register();
		
		var context:Context = builder.build();
		var targetInstance:SimpleInjectionTarget = context.getObjectByType(SimpleInjectionTarget) as SimpleInjectionTarget;
		
		assertThat(targetInstance.fromConstructor, isA(InjectedDependency));
		assertThat(targetInstance.fromProperty, isA(InjectedDependency));
		assertThat(targetInstance.fromMethod, isA(InjectedDependency));
		assertThat(targetInstance.fromConstructor, not(sameInstance(targetInstance.fromProperty)));
		assertThat(targetInstance.fromConstructor, not(sameInstance(targetInstance.fromMethod)));
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.MessageReceiverCache;
import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandManager;
import org.spicefactory.parsley.core.state.manager.GlobalDomainManager;

class MessageRouterDecorator implements MessageRouter {
	
	public static var initCount:int;
	public static var messageCount:int;
	
	private var delegate:MessageRouter;
	
	
	function MessageRouterDecorator (delegate:MessageRouter) {
		this.delegate = delegate;
	}
	
	public function init (settings:MessageSettings, domainManager:GlobalDomainManager, isLifecylceEventRouter:Boolean) : void {
		initCount++;
		delegate.init(settings, domainManager, isLifecylceEventRouter);
	}
	
	public function getReceiverCache (type:ClassInfo) : MessageReceiverCache {
		return delegate.getReceiverCache(type);
	}
	
	public function dispatchMessage (message:Message, joinCaches:Array = null) : void {
		messageCount++;
		delegate.dispatchMessage(message, joinCaches);
	}

	public function observeCommand (command:Command, joinCaches:Array = null) : void {
		delegate.observeCommand(command, joinCaches);
	}

	public function get receivers () : MessageReceiverRegistry {
		return delegate.receivers;
	}
	
	public function get commandManager() : CommandManager {
		return delegate.commandManager;
	}
	
}
