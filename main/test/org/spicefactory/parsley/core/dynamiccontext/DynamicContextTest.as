package org.spicefactory.parsley.core.dynamiccontext {
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicContext;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.tag.messaging.MessageHandlerDecorator;

/**
 * @author Jens Halm
 */
public class DynamicContextTest extends ContextTestBase {

	
	public function testAddObject () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var obj:AnnotatedDynamicTestObject = new AnnotatedDynamicTestObject();
		var dynContext:DynamicContext = context.createDynamicContext();
		var dynObject:DynamicObject = dynContext.addObject(obj);
		validateDynamicObject(dynObject, context);
	}
	
	public function testAddObjectAndDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var obj:DynamicTestObject = new DynamicTestObject();
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext);
		var dynObject:DynamicObject = dynContext.addObject(obj, definition);
		validateDynamicObject(dynObject, context);		
	}	
	
	public function testAddDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		checkState(context);
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext);
		var dynObject:DynamicObject = dynContext.addDefinition(definition);
		validateDynamicObject(dynObject, context);
	}
	
	public function testNestedDefinitionLifecycle () : void {
		var context:Context = RuntimeContextBuilder.build([]);
		checkState(context);
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext, false);
		var dynObject:DynamicObject = dynContext.addDefinition(definition);
		var instance:DynamicTestObject = dynObject.instance as DynamicTestObject;
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
	
	private function createDefinition (context:DynamicContext, dependencyAsRef:Boolean = true) : ObjectDefinition {
		var decorator:MessageHandlerDecorator = new MessageHandlerDecorator();
		decorator.method = "handleMessage";
		var registry:ObjectDefinitionRegistry = DefaultContext(context).registry;
		var definition:ObjectDefinition = registry.builders
					.forNestedDefinition(DynamicTestObject)
					.decorator(decorator)
					.build();
		if (dependencyAsRef) {
			definition.properties.addTypeReference("dependency");
		}
		else {
			var childDef:ObjectDefinition = registry.builders
					.forNestedDefinition(DynamicTestDependency)
					.build();
			definition.properties.addValue("dependency", childDef);
		}
		return definition;
	}


	
}
}
