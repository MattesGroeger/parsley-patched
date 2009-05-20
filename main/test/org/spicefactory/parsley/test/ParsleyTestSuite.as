package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.core.builder.ActionScriptObjectDefinitionBuilderTest;
import org.spicefactory.parsley.core.decorator.factory.FactoryDecoratorTest;
import org.spicefactory.parsley.core.decorator.injection.InjectionDecoratorTest;
import org.spicefactory.parsley.core.decorator.lifecycle.LifecycleDecoratorTest;
import org.spicefactory.parsley.core.decorator.injection.MissingConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredConstructorInjection;
import org.spicefactory.parsley.core.messaging.MessagingTest;

public class ParsleyTestSuite {
	

	public static function suite () : TestSuite {
		
		/* workaround for Flash Reflection Bug */
		new RequiredConstructorInjection(null);
		new MissingConstructorInjection(null);
		new OptionalConstructorInjection(null);
		
		var suite:TestSuite = new TestSuite();
		suite.addTestSuite(ActionScriptObjectDefinitionBuilderTest);
		suite.addTestSuite(InjectionDecoratorTest);
		suite.addTestSuite(LifecycleDecoratorTest);
		suite.addTestSuite(FactoryDecoratorTest);
		suite.addTestSuite(MessagingTest);
		return suite;
	}
	
	
}

}