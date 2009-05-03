package org.spicefactory.parsley.core {
import org.spicefactory.parsley.testmodel.LazyTestClass;
import org.spicefactory.parsley.testmodel.ClassWithSimpleProperties;

import flexunit.framework.TestCase;

/**
 * @author Jens Halm
 */
public class ActionScriptObjectDefinitionBuilderTest extends TestCase {
	
	
	
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
	
	
	private function checkState (context:Context, configured:Boolean = true, initialized:Boolean = true, destroyed:Boolean = false) : void {
		assertEquals("Unexpected configured state", configured, context.configured);
		assertEquals("Unexpected initialized state", initialized, context.initialized);
		assertEquals("Unexpected destroyed state", destroyed, context.destroyed);		
	}
	
	
	private function checkObjectIds (context:Context, expectedIds:Array, type:Class = null) : void {
		assertEquals("Unexpected number of objects", expectedIds.length, context.getObjectCount(type));
		var actualIds:Array = context.getObjectIds(type);
		actualIds.sort();
		expectedIds.sort();
		assertEquals("Unexpected number of ids", expectedIds.length, actualIds.length);
		for (var i:int = 0; i < expectedIds.length; i++) {
			assertTrue("Expected containsObject to return true", context.containsObject(expectedIds[i]));
			assertEquals("Unexpected object id", expectedIds[i], actualIds[i]);
		}
	}
	
	private function getAndCheckObject (context:Context, id:String, expectedType:Class, 
			singleton:Boolean = true, typeUnique:Boolean = true) : Object {
		var actualType:Class = context.getType(id);
		assertEquals("Unexpected type returned by getType", expectedType, actualType);
		var obj1:Object = context.getObject(id);
		assertTrue("Unexpected type returned by getObject", (obj1 is expectedType));
		var obj2:Object;
		if (typeUnique) {
			obj2 = context.getObjectByType(expectedType);
			assertTrue("Unexpected type returned by getObjectByType", (obj2 is expectedType));
		}
		else {
			obj2 = context.getObject(id);
		}
		if (singleton) {
			assertTrue("Expected singleton instance", obj1 === obj2);
		}
		else {
			assertFalse("Expected prototype instance", obj1 === obj2);
		}
		return obj1;
	}
	
	
}
}
