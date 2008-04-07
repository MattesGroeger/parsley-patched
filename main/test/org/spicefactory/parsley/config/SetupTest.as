package org.spicefactory.parsley.config {
	
	import org.spicefactory.parsley.config.testmodel.ClassA;
	import org.spicefactory.parsley.config.util.CustomVariableResolver;
	import org.spicefactory.parsley.context.ApplicationContext;
	import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;	
	
public class SetupTest extends ApplicationContextParserTest {
	

	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	public function testVariableExpression () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		        <expressions>
		            <variable name="test"><uint>34</uint></variable>
		        </expressions>
		    </setup>
    		<factory>
    			<object id="uintProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="uintProp" value="${test}"/>
    			</object>
    		</factory>
    	</application-context>;  
    	parseForContext("uintProp", xml, onTestVariableExpression); 
	}	
	
	private function onTestVariableExpression (context:ApplicationContext) : void {
		assertStrictlyEquals("Expecting 1 object in context", 1, context.objectCount);
    	var obj:Object = context.getObject("uintProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertStrictlyEquals("Unexpected property value", 34, classA.uintProp);
	}
	
	public function testReferenceExpression () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="stringProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="stringProp" value="${ref.nullProp}"/>
    			</object>
    			<object id="ref" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    		</factory>
    	</application-context>;  
    	parseForContext("stringProp", xml, onTestReferenceExpression); 
	}	
	
	private function onTestReferenceExpression (context:ApplicationContext) : void {
		assertStrictlyEquals("Unexpected object count", 2, context.objectCount);
    	var obj:Object = context.getObject("stringProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertStrictlyEquals("Unexpected property value", "initialValue", classA.stringProp);		
	}
	
	public function testCustomResolver () : void {
		var resolver:CustomVariableResolver = null; // just to compile
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		        <expressions>
		            <variable-resolver type="org.spicefactory.parsley.config.util.CustomVariableResolver"/>
		        </expressions>
		    </setup>
    		<factory>
    			<object id="stringProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="stringProp" value="${foo}"/>
    			</object>
    		</factory>
    	</application-context>;  
    	parseForContext("stringProp", xml, onTestCustomResolver); 
	}	
	
	private function onTestCustomResolver (context:ApplicationContext) : void {
		assertStrictlyEquals("Expecting 1 object in context", 1, context.objectCount);
    	var obj:Object = context.getObject("stringProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertStrictlyEquals("Unexpected property value", "bar", classA.stringProp);
	}
	
	public function testStaticInitializerProperty () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		        <static-initializers>
		            <static type="org.spicefactory.parsley.config.testmodel.ClassA">
		                <property name="staticProp" value="foo"/>
		            </static>
		        </static-initializers>
		    </setup>
    	</application-context>;  
    	parseForContext("staticProp", xml, onTestStaticInitializerProperty); 
	}	
	
	private function onTestStaticInitializerProperty (context:ApplicationContext) : void {
		assertStrictlyEquals("Unexpected object count", 0, context.objectCount);
    	assertStrictlyEquals("Unexpected static property value", "foo", ClassA.staticProp);
	}
	
	public function testStaticInitializerMethod () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		        <static-initializers>
		            <static type="org.spicefactory.parsley.config.testmodel.ClassA">
		                <init-method name="staticTestMethod"/>
		            </static>
		        </static-initializers>
		    </setup>
    	</application-context>;  
    	parseForContext("staticMethod", xml, onTestStaticInitializerMethod); 
	}	
	
	private function onTestStaticInitializerMethod (context:ApplicationContext) : void {
		assertStrictlyEquals("Unexpected object count", 0, context.objectCount);
    	assertTrue("Static method has not been called", ClassA.staticTestMethodCalled);
	}
	
}

}