package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.decorator.injection.RequiredMethodInjection;
import org.spicefactory.parsley.flex.mxmlconfig.factory.TestFactory;

/**
 * @author Jens Halm
 */
public class FactoryXmlTagTest extends XmlContextTestBase {

	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="dependency" type="org.spicefactory.parsley.core.decorator.injection.InjectedDependency"/>
		
		<object id="factoryWithDependency" type="org.spicefactory.parsley.flex.mxmlconfig.factory.TestFactory">
			<factory method="createInstance"/>
		</object> 
	</objects>; 

	
	public function testFactoryWithDependency () : void {
		var context:Context = getContext(config);
		checkState(context);
		checkObjectIds(context, ["factoryWithDependency"], RequiredMethodInjection);	
		assertTrue("Expected Factory to be accessible in Context", 1, context.getObjectIds(TestFactory).length);
		var obj:RequiredMethodInjection 
				= getAndCheckObject(context, "factoryWithDependency", RequiredMethodInjection) as RequiredMethodInjection;
		assertNotNull("Missing dependency", obj.dependency);
	}
	
	
}
}
