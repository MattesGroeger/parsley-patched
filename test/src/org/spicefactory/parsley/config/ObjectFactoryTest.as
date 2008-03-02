package org.spicefactory.parsley.config {

import flash.events.Event;

import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.config.testmodel.ClassB;
import org.spicefactory.parsley.config.testmodel.ClassC;
import org.spicefactory.parsley.config.testmodel.ClassD;
import org.spicefactory.parsley.config.testmodel.TestEventDispatcher;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;
	
	
public class ObjectFactoryTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	
	public function testMethodCallWithoutArgs () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<init-method name="testMethod"/>
    			</object>
    		</factory>
    	</application-context>;
    	var obj:ClassA = parseForSingleObject2("obj", xml, ClassA) as ClassA;  
    	assertTrue("testMethod was not called", obj.testMethodCalled);
 	}
 	
	public function testMethodCallWithArgs () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<init-method name="testMethodWithArgs">
    				    <array>
    				        <string>Yo</string>
    				    </array>
    				    <uint>42</uint>
    				    <boolean>false</boolean>
    				</init-method>
    			</object>
    		</factory>
    	</application-context>;
    	var obj:ClassA = parseForSingleObject2("obj", xml, ClassA) as ClassA;  
    	var args:Array = obj.testMethodArgs;
    	assertNotNull("Arguments of testMethod not available", args);
    	assertStrictlyEquals("Unexpected Array length", args[0].length, 1);
    	assertStrictlyEquals("Unexpected Argument", args[0][0], "Yo");
    	assertStrictlyEquals("Unexpected Argument", args[1], 42);
    	assertStrictlyEquals("Unexpected Argument", args[2], false);
 	}
 	
 	public function testListenerRegistration () : void {
 		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassD">
    				<listener event-type="foo" dispatcher="dispatcher" method="handleEvent"/>
    			</object>
    			<object id="dispatcher" type="org.spicefactory.parsley.config.testmodel.TestEventDispatcher"/>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	var obj:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expected instance of type ClassC", (obj is ClassD));
    	var dispObj:Object = context.getObject("dispatcher");
    	assertNotNull("Expecting Object instance", dispObj);
    	assertTrue("Expected instance of type ClassC", (dispObj is TestEventDispatcher));
    	var dispatcher:TestEventDispatcher = TestEventDispatcher(dispObj);
    	var listener:ClassD = ClassD(obj);
    	assertEquals("Unexpected event count", 0, listener.getAllEvents().length); 
    	dispatcher.dispatchEvent(new Event("foo"));
    	assertEquals("Unexpected event count", 1, listener.getAllEvents().length); 
    	dispatcher.dispatchEvent(new Event("bar")); // does not listen to
    	assertEquals("Unexpected event count", 1, listener.getAllEvents().length); 
 	}
 	
	public function testConstructorArgs () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassC">
    				<constructor-args>
    				    <object-ref id="classB"/>
    				    <number>3.5</number>
    				</constructor-args>
    			</object>
    			<object id="classB" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	var obj:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expected instance of type ClassC", (obj is ClassC));
    	var classC:ClassC = obj as ClassC;
    	assertTrue("Reference was not set", (classC.ref is ClassB));
    	assertStrictlyEquals("Unexpected constructor arg", 3.5, classC.num);
 	}
 	
	public function testStaticFactoryMethod () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<static-factory-method type="org.spicefactory.parsley.config.testmodel.ClassA" method="getInstance"/>
    			</object>
    		</factory>
    	</application-context>;
    	var obj:ClassA = parseForSingleObject2("obj", xml, ClassA) as ClassA;  
 	}
 	
 	public function testInstanceFactoryMethod () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<factory-method factory="factory" method="createClassAInstance">
						<string>arg</string>    				
    				</factory-method>
    			</object>
    			<object id="factory" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	var obj:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expected instance of type ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertStrictlyEquals("Unexpected property value", "arg", classA.stringProp);
 	}
 	
 	public function testSingletonObject () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	var obj1:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance", obj1);	
    	var obj2:Object = context.getObject("obj");
    	assertTrue("Object is not a singleton", (obj1 === obj2));	
 	}
 	
 	public function testNonSingletonObject () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" singleton="false" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	var obj1:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance (1)", obj1);	
    	var obj2:Object = context.getObject("obj");
    	assertNotNull("Expecting Object instance (2)", obj2);
    	assertTrue("Object is a singleton", (obj1 !== obj2));	
 	}
 	
 	public function testLazyAttribute () : void {
 		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="eager" lazy="false" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    			<object id="lazy" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    		</factory>
    	</application-context>; 
    	ClassA.clearInstanceCount();
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	assertEquals("Unexpected instance count", 1, ClassA.instanceCount);
    	context.getObject("lazy");
    	assertEquals("Unexpected instance count", 2, ClassA.instanceCount);
    	context.getObject("eager"); // object already created, count should not change
    	assertEquals("Unexpected instance count", 2, ClassA.instanceCount);	
 	}
 	
 	public function testDestroyMethod () : void {
 		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="obj" type="org.spicefactory.parsley.config.testmodel.ClassA">
    			    <destroy-method name="testMethod"/>
    			</object>
    		</factory>
    	</application-context>; 
    	var obj:ClassA = parseForSingleObject2("obj", xml, ClassA) as ClassA;  
    	currentContext.destroy();
    	assertTrue("Destroy method was not called", obj.testMethodCalled);
 	}
 	
 	
	
}

}