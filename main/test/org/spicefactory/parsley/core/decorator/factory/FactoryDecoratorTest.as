package org.spicefactory.parsley.core.decorator.factory {
	import org.spicefactory.parsley.core.decorator.injection.RequiredMethodInjection;
	import org.spicefactory.parsley.core.decorator.factory.FactoryDecoratorTestContainer;
	import org.spicefactory.parsley.core.decorator.factory.TestFactory;
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;

/**
 * @author Jens Halm
 */
public class FactoryDecoratorTest extends ContextTestBase {

	
	public function testFactoryWithDependency () : void {
		var context:Context = ActionScriptContextBuilder.build(FactoryDecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["factoryWithDependency"], RequiredMethodInjection);	
		assertTrue("Expected Factory to be accessible in Context", 1, context.getObjectIds(TestFactory).length);
		var obj:RequiredMethodInjection 
				= getAndCheckObject(context, "factoryWithDependency", RequiredMethodInjection) as RequiredMethodInjection;
		assertNotNull("Missing dependency", obj.dependency);
	}
	
	
}
}
