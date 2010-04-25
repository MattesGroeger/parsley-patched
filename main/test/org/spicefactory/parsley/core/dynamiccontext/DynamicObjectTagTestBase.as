package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.tag.messaging.MessageHandlerDecorator;

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
