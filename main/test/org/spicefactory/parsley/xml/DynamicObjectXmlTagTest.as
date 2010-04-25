package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.dynamiccontext.DynamicObjectTagTestBase;

/**
 * @author Jens Halm
 */
public class DynamicObjectXmlTagTest extends DynamicObjectTagTestBase {
	
	
	public override function get dynamicContext () : Context {
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<dynamic-object id="testObject" type="org.spicefactory.parsley.core.dynamiccontext.AnnotatedDynamicTestObject">
			<property name="dependency">
				<object type="org.spicefactory.parsley.core.dynamiccontext.DynamicTestDependency"/>
			</property>
		</dynamic-object> 
	
	</objects>;	
}
}
