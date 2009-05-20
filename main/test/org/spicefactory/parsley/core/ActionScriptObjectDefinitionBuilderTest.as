package org.spicefactory.parsley.core {
import org.spicefactory.parsley.testmodel.LazyTestClass;
import org.spicefactory.parsley.testmodel.ClassWithSimpleProperties;

import flexunit.framework.TestCase;

/**
 * @author Jens Halm
 */
public class ActionScriptObjectDefinitionBuilderTest extends ContextTestBase {

	
	
	public function testEmptyContext () : void {
		var context:Context = ActionScriptContextBuilder.build(EmptyContainer);
		checkState(context);
		checkObjectIds(context, []);
	}
	
	
	public function testObjectWithSimpleProperties () : void {
		var context:Context = ActionScriptContextBuilder.build(Container1);
		checkState(context);
		checkObjectIds(context, ["simpleObject"]);	
		checkObjectIds(context, ["simpleObject"], ClassWithSimpleProperties);	
		checkObjectIds(context, [], Container1);	
		var obj:ClassWithSimpleProperties = getAndCheckObject(context, "simpleObject", ClassWithSimpleProperties) as ClassWithSimpleProperties;
		assertEquals("Unexpected boolean property", true, obj.booleanProp);	
		assertEquals("Unexpected int property", 7, obj.intProp);	
		assertEquals("Unexpected String property", "foo", obj.stringProp);	
	}


	public function testOverwrittenId () : void {
		var context:Context = ActionScriptContextBuilder.build(Container2);
		checkState(context);
		checkObjectIds(context, ["foo", "prototypeInstance", "lazyInstance", "eagerInstance"]);	
		checkObjectIds(context, ["foo", "prototypeInstance"], ClassWithSimpleProperties);	
		getAndCheckObject(context, "foo", ClassWithSimpleProperties, true, false);		
	}
	
	public function testPrototypeInstance () : void {
		var context:Context = ActionScriptContextBuilder.build(Container2);
		checkState(context);
		checkObjectIds(context, ["foo", "prototypeInstance", "lazyInstance", "eagerInstance"]);	
		checkObjectIds(context, ["foo", "prototypeInstance"], ClassWithSimpleProperties);	
		getAndCheckObject(context, "prototypeInstance", ClassWithSimpleProperties, false, false);		
	}
	
	public function testLazyness () : void {
		LazyTestClass.instanceCount = 0;
		var context:Context = ActionScriptContextBuilder.build(Container2);
		checkState(context);
		checkObjectIds(context, ["foo", "prototypeInstance", "lazyInstance", "eagerInstance"]);	
		checkObjectIds(context, ["lazyInstance", "eagerInstance"], LazyTestClass);
		assertEquals("Unexpected object count", 1, LazyTestClass.instanceCount);	
		getAndCheckObject(context, "lazyInstance", LazyTestClass, true, false);		
		assertEquals("Unexpected object count", 2, LazyTestClass.instanceCount);	
		getAndCheckObject(context, "eagerInstance", LazyTestClass, true, false);		
		assertEquals("Unexpected object count", 2, LazyTestClass.instanceCount);	
	}
	
	
}
}