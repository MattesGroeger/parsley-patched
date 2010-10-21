package org.spicefactory.parsley.test {
import flexunit.framework.TestSuite;

import org.spicefactory.parsley.binding.BindingMetadataTest;
import org.spicefactory.parsley.core.builder.ActionScriptConfigurationTest;
import org.spicefactory.parsley.core.builder.RuntimeConfigurationTest;
import org.spicefactory.parsley.core.command.CommandMetadataTagTest;
import org.spicefactory.parsley.core.command.sync.SynchronousCommandTest;
import org.spicefactory.parsley.core.command.task.TaskCommandTest;
import org.spicefactory.parsley.core.context.ContextTest;
import org.spicefactory.parsley.core.decorator.asyncinit.AsyncInitMetadataTagTest;
import org.spicefactory.parsley.core.decorator.factory.FactoryMetadataTagTest;
import org.spicefactory.parsley.core.decorator.injection.InjectMetadataTagTest;
import org.spicefactory.parsley.core.decorator.injection.MissingConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredConstructorInjection;
import org.spicefactory.parsley.core.decorator.lifecycle.LifecycleMetadataTagTest;
import org.spicefactory.parsley.core.decorator.lifecycle.ObserveMetadataTagTest;
import org.spicefactory.parsley.core.decorator.metadata.MetadataInheritanceTest;
import org.spicefactory.parsley.core.dynamiccontext.DynamicObjectTest;
import org.spicefactory.parsley.core.dynamiccontext.LegacyDynamicContextTest;
import org.spicefactory.parsley.core.messaging.ErrorPolicyTest;
import org.spicefactory.parsley.core.messaging.LazyMessagingMetadataTagTest;
import org.spicefactory.parsley.core.messaging.MessagingMetadataTagTest;
import org.spicefactory.parsley.core.messaging.proxy.MessageProxyTest;
import org.spicefactory.parsley.core.properties.ConfigurationPropertiesTest;
import org.spicefactory.parsley.core.scope.ScopeTest;
import org.spicefactory.parsley.dsl.DslConfigTest;
import org.spicefactory.parsley.flash.logging.FlashLoggingXmlTagTest;
import org.spicefactory.parsley.flash.resources.FlashResourcesTest;
import org.spicefactory.parsley.flex.logging.FlexLoggingXmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.binding.BindingMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.command.CommandMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.command.DynamicCommandMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.core.CoreMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.dynamicobject.DynamicObjectMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.factory.FactoryMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.lifecycle.LifecycleMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.messaging.MessagingMxmlTagTest;
import org.spicefactory.parsley.flex.mxmlconfig.observer.ObserveMxmlTagTest;
import org.spicefactory.parsley.pimento.PimentoMxmlTagTest;
import org.spicefactory.parsley.pimento.PimentoXmlTagTest;
import org.spicefactory.parsley.xml.AsyncInitXmlTagTest;
import org.spicefactory.parsley.xml.BindingXmlTagTest;
import org.spicefactory.parsley.xml.CommandXmlTagTest;
import org.spicefactory.parsley.xml.CoreXmlTagTest;
import org.spicefactory.parsley.xml.DynamicCommandXmlTagTest;
import org.spicefactory.parsley.xml.DynamicObjectXmlTagTest;
import org.spicefactory.parsley.xml.ExternalXmlConfigTest;
import org.spicefactory.parsley.xml.FactoryXmlTagTest;
import org.spicefactory.parsley.xml.LifecycleXmlTagTest;
import org.spicefactory.parsley.xml.MessagingXmlTagTest;
import org.spicefactory.parsley.xml.ObserveXmlTagTest;

public class ParsleyTestSuite {
	

	public static function suite () : TestSuite {
		
		/* workaround for Flash Reflection Bug */
		new RequiredConstructorInjection(null);
		new MissingConstructorInjection(null);
		new OptionalConstructorInjection(null);
		
		var suite:TestSuite = new TestSuite();
		
		suite.addTestSuite(ContextTest);
		suite.addTestSuite(ActionScriptConfigurationTest);
		suite.addTestSuite(RuntimeConfigurationTest);
		suite.addTestSuite(DslConfigTest);
		suite.addTestSuite(ConfigurationPropertiesTest);
		suite.addTestSuite(MetadataInheritanceTest);

		suite.addTestSuite(InjectMetadataTagTest);

		suite.addTestSuite(AsyncInitMetadataTagTest);
		suite.addTestSuite(AsyncInitMxmlTagTest);
		suite.addTestSuite(AsyncInitXmlTagTest);
		
		suite.addTestSuite(FactoryMetadataTagTest);
		suite.addTestSuite(FactoryMxmlTagTest);
		suite.addTestSuite(FactoryXmlTagTest);

		suite.addTestSuite(LifecycleMetadataTagTest);
		suite.addTestSuite(LifecycleMxmlTagTest);
		suite.addTestSuite(LifecycleXmlTagTest);
		
		suite.addTestSuite(ObserveMetadataTagTest);
		suite.addTestSuite(ObserveMxmlTagTest);
		suite.addTestSuite(ObserveXmlTagTest);

		suite.addTestSuite(MessagingMetadataTagTest);
		suite.addTestSuite(LazyMessagingMetadataTagTest);
		suite.addTestSuite(MessagingMxmlTagTest);
		suite.addTestSuite(MessagingXmlTagTest);
		suite.addTestSuite(MessageProxyTest);

		suite.addTestSuite(CommandMetadataTagTest);
		suite.addTestSuite(CommandMxmlTagTest);
		suite.addTestSuite(CommandXmlTagTest);

		suite.addTestSuite(ErrorPolicyTest);

		suite.addTestSuite(TaskCommandTest);
		suite.addTestSuite(SynchronousCommandTest);

		suite.addTestSuite(DynamicCommandMxmlTagTest);
		suite.addTestSuite(DynamicCommandXmlTagTest);

		suite.addTestSuite(BindingMetadataTest);
		suite.addTestSuite(BindingMxmlTagTest);
		suite.addTestSuite(BindingXmlTagTest);

		suite.addTestSuite(ScopeTest);

		suite.addTestSuite(CoreMxmlTagTest);
		suite.addTestSuite(CoreXmlTagTest);

		suite.addTestSuite(DynamicObjectMxmlTagTest);
		suite.addTestSuite(DynamicObjectXmlTagTest);
		suite.addTestSuite(DynamicObjectTest);
		suite.addTestSuite(LegacyDynamicContextTest);

		suite.addTestSuite(ExternalXmlConfigTest);

		suite.addTestSuite(FlashLoggingXmlTagTest);
		suite.addTestSuite(FlexLoggingXmlTagTest);

		suite.addTestSuite(FlashResourcesTest);

		suite.addTestSuite(PimentoXmlTagTest);
		suite.addTestSuite(PimentoMxmlTagTest);

		return suite;

	}
	
	
}

}