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
		assertThat(MessageRouterDecorator.messageCount, equalTo(2));
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

import org.spicefactory.parsley.core.messaging.MessageReceiverRegistry;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.messaging.command.CommandManager;

import flash.system.ApplicationDomain;

class MessageRouterDecorator implements MessageRouter {
	
	public static var initCount:int;
	public static var messageCount:int;
	
	private var delegate:MessageRouter;
	
	
	function MessageRouterDecorator (delegate:MessageRouter) {
		this.delegate = delegate;
	}
	
	public function init (settings:MessageSettings, isLifecylceEventRouter:Boolean) : void {
		initCount++;
	}
	
	public function dispatchMessage (message:Object, domain:ApplicationDomain, selector:* = undefined) : void {
		messageCount++;
		delegate.dispatchMessage(message, domain);
	}
	
	public function get receivers () : MessageReceiverRegistry {
		return delegate.receivers;
	}
	
	public function get commandManager() : CommandManager {
		return delegate.commandManager;
	}
	
}
