package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.parsley.core.context.ContextUtil;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.config.Configurations;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.tag.model.NestedObject;

/**
 * @author Jens Halm
 */
public class DynamicObjectTest extends ContextTestBase {

	
	public function testAddObject () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var obj:AnnotatedDynamicTestObject = new AnnotatedDynamicTestObject();
		var dynObject:DynamicObject = context.addDynamicObject(obj);
		validateDynamicObject(dynObject, context);
	}
	
	public function testAddObjectAndDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var obj:DynamicTestObject = new DynamicTestObject();
		var definition:DynamicObjectDefinition = createDefinition(context);
		var dynObject:DynamicObject = context.addDynamicObject(obj, definition);
		validateDynamicObject(dynObject, context);		
	}	
	
	public function testAddDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var definition:DynamicObjectDefinition = createDefinition(context);
		var dynObject:DynamicObject = context.addDynamicDefinition(definition);
		validateDynamicObject(dynObject, context);
	}
	
	public function testNestedDefinitionLifecycle () : void {
		var context:Context = RuntimeContextBuilder.build([]);
		checkState(context);
		var definition:DynamicObjectDefinition = createDefinition(context, false);
		var dynObject:DynamicObject = context.addDynamicDefinition(definition);
		var instance:DynamicTestObject = dynObject.instance as DynamicTestObject;
		assertFalse("Unexpected destroy method invocation", instance.dependency.destroyMethodCalled);
		validateDynamicObject(dynObject, context);
		assertTrue("Expected destroy method invocation", instance.dependency.destroyMethodCalled);
	}
	
	public function testContextUtil () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var obj:AnnotatedDynamicTestObject = new AnnotatedDynamicTestObject();
		assertFalse("Unexpected result for isManaged", ContextUtil.isManaged(obj));
		assertNull("Expected null for Context lookup", ContextUtil.getContext(obj));
		var dynObject:DynamicObject = context.addDynamicObject(obj);
		assertTrue("Unexpected result for isManaged", ContextUtil.isManaged(obj));
		assertEquals("Unexpected result for Context lookup", context, ContextUtil.getContext(obj));
		dynObject.remove();
		assertFalse("Unexpected result for isManaged", ContextUtil.isManaged(obj));
		assertNull("Expected null for Context lookup", ContextUtil.getContext(obj));
	}

	private function validateDynamicObject (dynObject:DynamicObject, context:Context) : void {
		assertNotNull("Unresolved dependency", dynObject.instance.dependency);
		context.scopeManager.dispatchMessage(new Object());
		dynObject.remove();
		context.scopeManager.dispatchMessage(new Object());
		assertEquals("Unexpected number of received messsages", 1, dynObject.instance.getMessageCount());			
	}
	
	private function createDefinition (context:Context, dependencyAsRef:Boolean = true) : DynamicObjectDefinition {
		var registry:ObjectDefinitionRegistry = DefaultContext(context).registry;
		var builder:ObjectDefinitionBuilder 
				= Configurations.forRegistry(registry).builders.forClass(DynamicTestObject);
		builder.method("handleMessage").messageHandler();
		if (dependencyAsRef) {
			builder.property("dependency").injectByType();
		}
		else {
			var childDef:DynamicObjectDefinition = Configurations.forRegistry(registry).builders
					.forClass(DynamicTestDependency).asDynamicObject().build();
			builder.property("dependency").value(new NestedObject(childDef));
		}
		return builder.asDynamicObject().build();
	}


	
}
}
