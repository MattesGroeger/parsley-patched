package org.spicefactory.parsley.dsl {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import flexunit.framework.TestCase;

import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.testmodel.SimpleInjectionTarget;

/**
 * @author Jens Halm
 */
public class DslConfigTest extends TestCase {
	
	
	public function testFactoryReplacement () : void {
		var delegate:MessageRouterFactory = GlobalFactoryRegistry.instance.messageRouter;
		var originalErrorPolicy:ErrorPolicy = delegate.unhandledError;
		var factory:MessageRouterFactoryDecorator 
				= new MessageRouterFactoryDecorator(delegate);
		try {
			ContextBuilder.newSetup()
					.messagingSettings().unhandledError(ErrorPolicy.ABORT)
					.factories(true).messageRouter(factory)
					.newBuilder()
					.build();		
			assertEquals("Unexpected number of factory invocations", 2, factory.invocationCount);
			assertEquals("Unexpected error policy", ErrorPolicy.ABORT, delegate.unhandledError);
		}
		finally {
			delegate.unhandledError = originalErrorPolicy;
		}
	}
	
	public function testInjectFromDefinition () : void {
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
		
		assertTrue("Expected Constructor Injection", targetInstance.fromConstructor is InjectedDependency);
		assertTrue("Expected Property Injection", targetInstance.fromProperty is InjectedDependency);
		assertTrue("Expected Method Injection", targetInstance.fromMethod is InjectedDependency);
		
		assertTrue("Epxected three distinct instances", 
				(targetInstance.fromConstructor !== targetInstance.fromProperty 
				&& targetInstance.fromMethod !== targetInstance.fromProperty));	
	}
	
	
}
}

import org.spicefactory.parsley.core.factory.MessageRouterFactory;
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
	
	public function create () : MessageRouter {
		invocationCount++;
		return delegate.create();
	}
	
	public function get unhandledError () : ErrorPolicy {
		return delegate.unhandledError;
	}

	public function set unhandledError (policy:ErrorPolicy) : void {
		delegate.unhandledError = policy;
	}
	
	
}
