package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;

/**
 * @author Jens Halm
 */
public class DynamicObjectTagTestBase extends ContextTestBase {

	
	private var context:Context;
	
	public override function setUp () : void {
		super.setUp();
		context = dynamicContext;
		checkState(context);
	}
	
	public function testCreateObjectById () : void {
		var dynObject:DynamicObject = context.createDynamicObject("testObject");
		validateDynamicObject(dynObject, context);
	}
	
	public function testCreateObjectByType () : void {
		var dynObject:DynamicObject = context.createDynamicObjectByType(AnnotatedDynamicTestObject);
		validateDynamicObject(dynObject, context);		
	}	
	
	public function testAddDefinition () : void {
		var definition:DynamicObjectDefinition = context.getDefinition("testObject") as DynamicObjectDefinition;
		var dynObject:DynamicObject = context.addDynamicDefinition(definition);
		validateDynamicObject(dynObject, context);
	}
	
	public function testNestedDefinitionLifecycle () : void {
		var dynObject:DynamicObject = context.createDynamicObject("testObject");
		var instance:AnnotatedDynamicTestObject = dynObject.instance as AnnotatedDynamicTestObject;
		assertFalse("Unexpected destroy method invocation", instance.dependency.destroyMethodCalled);
		validateDynamicObject(dynObject, context);
		assertTrue("Expected destroy method invocation", instance.dependency.destroyMethodCalled);
	}
	
	public function testSynchronizedRootDynamicObjectLifecycle () : void {
		var dynObject:DynamicObject = context.createDynamicObject("testObjectWithRootRef");
		var instance:SimpleDynamicTestObject = dynObject.instance as SimpleDynamicTestObject;
		assertFalse("Unexpected destroy method invocation", instance.dependency.destroyMethodCalled);
		dynObject.remove();
		assertTrue("Expected destroy method invocation", instance.dependency.destroyMethodCalled);
	}

	private function validateDynamicObject (dynObject:DynamicObject, context:Context) : void {
		assertNotNull("Unresolved dependency", dynObject.instance.dependency);
		context.scopeManager.dispatchMessage(new Object());
		dynObject.remove();
		context.scopeManager.dispatchMessage(new Object());
		assertEquals("Unexpected number of received messsages", 1, dynObject.instance.getMessageCount());			
	}
	
	public function get dynamicContext () : Context {
		throw new AbstractMethodError();
	}


	
}
}
