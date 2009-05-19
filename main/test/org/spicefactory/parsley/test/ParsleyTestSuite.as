package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.core.ActionScriptObjectDefinitionBuilderTest;
import org.spicefactory.parsley.core.decorator.InjectionDecoratorTest;

public class ParsleyTestSuite {
	

	public static function suite () : TestSuite {
		var suite:TestSuite = new TestSuite();
		suite.addTestSuite(ActionScriptObjectDefinitionBuilderTest);
		suite.addTestSuite(InjectionDecoratorTest);
		return suite;
	}
	
	
}

}