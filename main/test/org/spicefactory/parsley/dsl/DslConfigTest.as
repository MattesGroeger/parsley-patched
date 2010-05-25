package org.spicefactory.parsley.dsl {
import org.spicefactory.parsley.core.factory.MessageRouterFactory;
import flexunit.framework.TestCase;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

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
	
	
}
}

import org.spicefactory.parsley.core.messaging.receiver.MessageErrorHandler;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.ErrorPolicy;
import org.spicefactory.parsley.core.factory.MessageRouterFactory;


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
