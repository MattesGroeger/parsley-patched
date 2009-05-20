package org.spicefactory.parsley.flex.mxmlconfig.factory {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.decorator.injection.RequiredMethodInjection;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * @author Jens Halm
 */
public class FactoryMxmlTagTest extends ContextTestBase {

	
	public function testFactoryWithDependency () : void {
		var context:Context = FlexContextBuilder.build(FactoryMxmlTagContainer);
		checkState(context);
		checkObjectIds(context, ["factoryWithDependency"], RequiredMethodInjection);	
		assertTrue("Expected Factory to be accessible in Context", 1, context.getObjectIds(TestFactory).length);
		var obj:RequiredMethodInjection 
				= getAndCheckObject(context, "factoryWithDependency", RequiredMethodInjection) as RequiredMethodInjection;
		assertNotNull("Missing dependency", obj.dependency);
	}
	
	
}
}
