package org.spicefactory.parsley.core.builder {
	import org.spicefactory.parsley.core.dynamiccontext.DynamicTestDependency;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.parsley.core.dynamiccontext.AnnotatedDynamicTestObject;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.runtime.processor.RuntimeConfigurationProcessor;
import org.spicefactory.parsley.testmodel.ClassWithSimpleProperties;

/**
 * @author Jens Halm
 */
public class RuntimeConfigurationTest extends ContextTestBase {
	
	
	
	public function test2objectsWithoutIds () : void {
		var dep:DynamicTestDependency = new DynamicTestDependency();
		var obj:AnnotatedDynamicTestObject = new AnnotatedDynamicTestObject();
		var context:Context = RuntimeContextBuilder.build([dep, obj]);
		checkState(context);
		assertEquals("Unexpected total object count", 2, context.getObjectCount());
		assertEquals("Unexpected object count for InjectedDependency", 1, context.getObjectCount(DynamicTestDependency));
		assertEquals("Unexpected object count for AnnotatedDynamicTestObject", 1, context.getObjectCount(AnnotatedDynamicTestObject));
		var obj2:AnnotatedDynamicTestObject = AnnotatedDynamicTestObject(context.getObjectByType(AnnotatedDynamicTestObject));
		assertEquals("Expected to retrieve existing instance", obj, obj2);
		assertEquals("Expected injected dependency", dep, obj2.dependency);
	}
	
	public function testObjectWithId () : void {
		var obj:ClassWithSimpleProperties = new ClassWithSimpleProperties();
		var builder:CompositeContextBuilder = new DefaultCompositeContextBuilder();
		var processor:RuntimeConfigurationProcessor = new RuntimeConfigurationProcessor();
		processor.addInstance(obj, "THE ID");
		builder.addProcessor(processor);
		var context:Context = builder.build();
		checkState(context);
		assertEquals("Unexpected total object count", 1, context.getObjectCount());
		assertEquals("Unexpected object count for ClassWithSimpleProperties", 1, context.getObjectCount(ClassWithSimpleProperties));
		assertEquals("Unexpected object count for Object", 1, context.getObjectCount(Object));
		assertTrue("Expected object with specified id", context.containsObject("THE ID"));
		assertTrue("Unexpected type of object", (context.getObject("THE ID") is ClassWithSimpleProperties));
	}
	
	public function testLazyClass () : void {
		SimpleClass.instanceCounter = 0;
		var builder:CompositeContextBuilder = new DefaultCompositeContextBuilder();
		var processor:RuntimeConfigurationProcessor = new RuntimeConfigurationProcessor();
		processor.addClass(SimpleClass, null, true, true);
		builder.addProcessor(processor);
		var context:Context = builder.build();
		checkState(context);
		assertEquals("Unexpected total object count", 1, context.getObjectCount());
		assertEquals("Unexpected object count for SimpleClass", 1, context.getObjectCount(SimpleClass));
		assertEquals("Unexpected total instance count for SimpleClass", 0, SimpleClass.instanceCounter);
		var obj:SimpleClass = SimpleClass(context.getObjectByType(SimpleClass));
		assertEquals("Unexpected total instance count for SimpleClass", 1, SimpleClass.instanceCounter);
		assertTrue("Expected init method to be called", obj.initCalled);
	}
}
}
