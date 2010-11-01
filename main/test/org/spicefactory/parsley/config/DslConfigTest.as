package org.spicefactory.parsley.config {
import org.hamcrest.object.sameInstance;
import org.hamcrest.core.not;
import org.hamcrest.core.isA;
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
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
	public function factoryReplacement () : void {
		var delegate:MessageRouterFactory = GlobalFactoryRegistry.instance.messageRouter;
		var originalErrorPolicy:ErrorPolicy = delegate.unhandledError;
		var factory:MessageRouterFactoryDecorator 
				= new MessageRouterFactoryDecorator(delegate);
		try {
			ContextBuilder.newSetup()
					.messageSettings().unhandledError(ErrorPolicy.ABORT)
					.factories(true).messageRouter(factory)
					.newBuilder()
					.build();	
			assertThat(factory.invocationCount, equalTo(2));
			assertThat(delegate.unhandledError, equalTo(ErrorPolicy.ABORT));	
		}
		finally {
			delegate.unhandledError = originalErrorPolicy;
		}
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

import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.MessageSettings;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;

class MessageRouterFactoryDecorator implements MessageRouterFactory {
	
	public var invocationCount:int;
	
	private var delegate:MessageRouterFactory;
	
	
	function MessageRouterFactoryDecorator (delegate:MessageRouterFactory) {
		this.delegate = delegate;
	}

	public function addErrorHandler (target:MessageErrorHandler) : void {
		delegate.addErrorHandler(target);
	}

	public function addCommandFactory (type:Class, factory:CommandFactory) : void {
		delegate.addCommandFactory(type, factory);
	}
	
	public function create (settings:MessageSettings, isLifecycleEventRouter:Boolean) : MessageRouter {
		invocationCount++;
		return delegate.create(settings, isLifecycleEventRouter);
	}

	public function get unhandledError () : ErrorPolicy {
		return delegate.unhandledError;
	}

	public function set unhandledError (policy:ErrorPolicy) : void {
		delegate.unhandledError = policy;
	}
	
	
}
