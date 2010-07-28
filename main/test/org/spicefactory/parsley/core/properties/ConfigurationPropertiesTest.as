package org.spicefactory.parsley.core.properties {
import org.spicefactory.parsley.asconfig.ActionScriptConfig;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.flex.FlexConfig;
import org.spicefactory.parsley.properties.Properties;
import org.spicefactory.parsley.xml.XmlConfig;

/**
 * @author Jens Halm
 */
public class ConfigurationPropertiesTest extends ContextTestBase {
	
	
	public const propString:String = "someValue = foo";
	
	public const propObject:Object = { someValue: "foo" };
	
	
	public function testAsConfigWithPropString () : void {
		var context:Context = ContextBuilder
			.newBuilder()
				.config(Properties.forString(propString))
				.config(ActionScriptConfig.forClass(PropertiesAsConfig))
				.build();
		validateContext(context);
	}
	
	public function testAsConfigWithPropObject () : void {
		var context:Context = ContextBuilder
			.newBuilder()
				.config(Properties.forObject(propObject))
				.config(ActionScriptConfig.forClass(PropertiesAsConfig))
				.build();
		validateContext(context);
	}
	
	public function testXmlConfig () : void {
		var config:XML = <objects 
			xmlns="http://www.spicefactory.org/parsley">
			<object id="object" type="org.spicefactory.parsley.core.properties.StringHolder">
				<property name="stringProp" value="${someValue}"/>
			</object> 
		</objects>; 
		var context:Context = ContextBuilder
			.newBuilder()
				.config(Properties.forString(propString))
				.config(XmlConfig.forInstance(config))
				.build();
		validateContext(context);
	}
	
	public function testMxmlConfig () : void {
		var context:Context = ContextBuilder
			.newBuilder()
				.config(Properties.forString(propString))
				.config(FlexConfig.forClass(PropertiesMxmlConfig))
				.build();
		validateContext(context);
	}
	
	
	private function validateContext (context:Context) : void {
		checkState(context);
		var obj:StringHolder 
				= getAndCheckObject(context, "object", StringHolder) as StringHolder;
		assertEquals("Unexpected string property", "foo", obj.stringProp);
	}
	
	
}
}
