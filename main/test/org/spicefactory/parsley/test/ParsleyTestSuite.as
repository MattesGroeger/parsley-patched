package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.core.ActionScriptObjectDefinitionBuilderTest;
import org.spicefactory.parsley.core.decorator.InjectionDecoratorTest;
import org.spicefactory.parsley.core.decorator.LifecycleDecoratorTest;
import org.spicefactory.parsley.core.decorator.MissingConstructorInjection;
import org.spicefactory.parsley.core.decorator.OptionalConstructorInjection;
import org.spicefactory.parsley.core.decorator.RequiredConstructorInjection;

public class ParsleyTestSuite {
	

	public static function suite () : TestSuite {
		
		/* workaround for Flash Reflection Bug */
		new RequiredConstructorInjection(null);
		new MissingConstructorInjection(null);
		new OptionalConstructorInjection(null);
		
		var suite:TestSuite = new TestSuite();
		//suite.addTestSuite(ActionScriptObjectDefinitionBuilderTest);
		//suite.addTestSuite(InjectionDecoratorTest);
		suite.addTestSuite(LifecycleDecoratorTest);
		return suite;
	}
	
	
}

}