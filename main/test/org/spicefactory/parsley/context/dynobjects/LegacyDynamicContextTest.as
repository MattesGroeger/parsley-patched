package org.spicefactory.parsley.context.dynobjects {
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.config.Configurations;
import org.spicefactory.parsley.context.dynobjects.model.AnnotatedDynamicTestObject;
import org.spicefactory.parsley.context.dynobjects.model.DynamicTestDependency;
import org.spicefactory.parsley.context.dynobjects.model.DynamicTestObject;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.DynamicContext;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.context.impl.DefaultContext;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.tag.model.NestedObject;
import org.spicefactory.parsley.util.contextInState;

/**
 * @author Jens Halm
 */
public class LegacyDynamicContextTest {

	
	[Test]
	public function addObject () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		assertThat(context, contextInState());
		var obj:AnnotatedDynamicTestObject = new AnnotatedDynamicTestObject();
		var dynContext:DynamicContext = context.createDynamicContext();
		var dynObject:DynamicObject = dynContext.addObject(obj);
		validateDynamicObject(dynObject, context);
	}
	
	[Test]
	public function addObjectAndDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		assertThat(context, contextInState());
		var obj:DynamicTestObject = new DynamicTestObject();
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext);
		var dynObject:DynamicObject = dynContext.addObject(obj, definition);
		validateDynamicObject(dynObject, context);		
	}	
	
	[Test]
	public function addDefinition () : void {
		var context:Context = ActionScriptContextBuilder.build(DynamicConfig);
		assertThat(context, contextInState());
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext);
		var dynObject:DynamicObject = dynContext.addDefinition(definition);
		validateDynamicObject(dynObject, context);
	}
	
	[Test]
	public function nestedDefinitionLifecycle () : void {
		var context:Context = RuntimeContextBuilder.build([]);
		assertThat(context, contextInState());
		var dynContext:DynamicContext = context.createDynamicContext();
		var definition:ObjectDefinition = createDefinition(dynContext, false);
		var dynObject:DynamicObject = dynContext.addDefinition(definition);
		var instance:DynamicTestObject = dynObject.instance as DynamicTestObject;
		assertThat(instance.dependency.destroyMethodCalled, equalTo(false));
		validateDynamicObject(dynObject, context);
		assertThat(instance.dependency.destroyMethodCalled, equalTo(true));
	}

	private function validateDynamicObject (dynObject:DynamicObject, context:Context) : void {
		assertThat(dynObject.instance.dependency, notNullValue());
		context.scopeManager.dispatchMessage(new Object());
		dynObject.remove();
		context.scopeManager.dispatchMessage(new Object());
		assertThat(dynObject.instance.getMessageCount(), equalTo(1));	
	}
	
	private function createDefinition (context:DynamicContext, dependencyAsRef:Boolean = true) : ObjectDefinition {
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
