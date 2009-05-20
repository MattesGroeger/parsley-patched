package org.spicefactory.parsley.core.decorator {
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;

/**
 * @author Jens Halm
 */
public class LifecycleDecoratorTest extends ContextTestBase {

	
	
	public function testPostConstruct () : void {
		var context:Context = ActionScriptContextBuilder.build(LifecycleDecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["postConstructModel"], PostConstructModel);	
		var obj:PostConstructModel 
				= getAndCheckObject(context, "postConstructModel", PostConstructModel) as PostConstructModel;
		assertTrue("PostConstruct method not called", obj.methodCalled);	
	}
	
	
	public function testPreDestroy () : void {
		var context:Context = ActionScriptContextBuilder.build(LifecycleDecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["preDestroyModel"], PreDestroyModel);	
		var obj:PreDestroyModel 
				= getAndCheckObject(context, "preDestroyModel", PreDestroyModel) as PreDestroyModel;
		context.destroy();
		assertTrue("PreDestroy method not called", obj.methodCalled);			
	}
	
	
	
}
}
