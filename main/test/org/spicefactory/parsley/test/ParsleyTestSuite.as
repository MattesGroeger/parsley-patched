package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.core.ActionScriptObjectDefinitionBuilderTest;

public class ParsleyTestSuite {
	

	public static function suite () : TestSuite {
		var suite:TestSuite = new TestSuite();
		suite.addTestSuite(ActionScriptObjectDefinitionBuilderTest);
		return suite;
	}
	
	
}

}