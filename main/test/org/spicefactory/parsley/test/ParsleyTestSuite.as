package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.core.builder.ActionScriptObjectDefinitionBuilderTest;
import org.spicefactory.parsley.core.decorator.asyncinit.AsyncInitTest;
import org.spicefactory.parsley.core.decorator.factory.FactoryDecoratorTest;
import org.spicefactory.parsley.core.decorator.injection.InjectionDecoratorTest;
import org.spicefactory.parsley.core.decorator.injection.MissingConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredConstructorInjection;
import org.spicefactory.parsley.core.decorator.lifecycle.LifecycleDecoratorTest;
import org.spicefactory.parsley.core.messaging.MessagingTest;
import org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.core.CoreMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.factory.FactoryMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.lifecycle.LifecycleMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.MessagingMxmlTagTest;
import org.spicefactory.parsley.xml.AsyncInitXmlTagTest;
import org.spicefactory.parsley.xml.CoreXmlTagTest;
import org.spicefactory.parsley.xml.FactoryXmlTagTest;
import org.spicefactory.parsley.xml.LifecycleXmlTagTest;
import org.spicefactory.parsley.xml.MessagingXmlTagTest;

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
		suite.addTestSuite(AsyncInitTest);
		suite.addTestSuite(CoreMxmlTagTest);
		suite.addTestSuite(LifecycleMxmlTagTest);
		suite.addTestSuite(FactoryMxmlTagTest);
		suite.addTestSuite(AsyncInitMxmlTagTest);
		suite.addTestSuite(MessagingMxmlTagTest);
		suite.addTestSuite(CoreXmlTagTest);
		suite.addTestSuite(LifecycleXmlTagTest);
		suite.addTestSuite(FactoryXmlTagTest);
		suite.addTestSuite(AsyncInitXmlTagTest);
		suite.addTestSuite(MessagingXmlTagTest);
		return suite;
	}
	
	
}

}