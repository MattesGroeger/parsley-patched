package org.spicefactory.parsley.config {

import flash.events.ErrorEvent;
import flash.events.IEventDispatcher;

import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.config.testmodel.ClassB;
import org.spicefactory.parsley.config.testmodel.ClassC;
import org.spicefactory.parsley.config.testmodel.ClassD;
import org.spicefactory.parsley.config.testmodel.TestEventDispatcher;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;

public class ApplicationContextTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	public function testAccessByName () : void {
		assertNull("root must be null", ApplicationContext.root);	
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"/>;
    	parseForContext2("emptyObject", xml);
    	assertNull("Unexpected root reference", ApplicationContext.root);
    	assertNotNull("Expected reference by name", ApplicationContext.forName("emptyObject"));
	}
	
	public function testDuplicateName () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd"/>;
    	parseForContext2("duplicate", xml, true);
    	parseForContextError("duplicate", xml);
	}
	
	public function testDuplicateRoot () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd"/>;
    	parseForContext2("duplicate", xml, true);
    	parseForContextError("duplicate2", xml, true);
	}
	
	public function testRootAccess () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd"/>;
    	parseForContext2("emptyObject", xml, true);
    	assertNotNull("Expected root reference", ApplicationContext.root);
    	assertNotNull("Expected reference by name", ApplicationContext.forName("emptyObject"));
	}
	
	public function testCacheable () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd"/>;
    	var context1:ApplicationContext = parseForContext2("emptyObject", xml, false, true);
    	var context2:ApplicationContext = parseForContext2("emptyObject", xml, false, true);
    	assertEquals("Expected the same context instance", context1, context2);
	}
	
	public function testInspectionForIds () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="eager" lazy="false" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    			<object id="lazy" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("eager"));
    	assertTrue("Expected object in context", context.containsObject("lazy"));
    	assertFalse("Unxpected object in context", context.containsObject("foo"));
    	var ids:Array = context.objectIds;
    	ids.sort();
    	assertEquals("Unexpected count of ids", 2, ids.length);
    	assertEquals("Unexpected object id", "eager", ids[0]);
    	assertEquals("Unexpected object id", "lazy", ids[1]);
	}
	
	public function testInspectionForTypes () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="aware" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    			<object id="classA1" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    			<object id="classA2" type="org.spicefactory.parsley.config.testmodel.ClassA"/>
    			<object id="dispatcher" type="org.spicefactory.parsley.config.testmodel.TestEventDispatcher"/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("obj", xml);  
    	assertEquals("Unexpected object count", 4, context.objectCount);
    	var check:Array = [
    		[ClassA, ClassA, ["classA1", "classA2"]], 
    		[ApplicationContextAware, ClassB, ["aware"]],
    		[IEventDispatcher, TestEventDispatcher, ["dispatcher"]],
    		[ClassC, ClassC, []],
    		[ClassB, ClassB, ["aware"]]
    		];
    	for each (var typeCheck:Array in check) {
    		var expectedType:Class = typeCheck[0];
    		var exactType:Class = typeCheck[1];
    		var expectedIds:Array = typeCheck[2];
    		var actualIds:Array = context.getIdsForType(expectedType);
    		var actualObjects:Array = context.getObjectsByType(expectedType);
    		actualIds.sort();
    		assertEquals("Unexpected number of ids for type " + expectedType, expectedIds.length, actualIds.length);
    		assertEquals("Unexpected number of objects for type " + expectedType, expectedIds.length, actualObjects.length);
    		for each (var expectedId:String in expectedIds) {
    			assertEquals("Unexpexted type", exactType, context.getType(expectedId));
    			assertEquals("Unexpected id", expectedId, actualIds.shift());
    		}
    	}
	}
	
	public function testParentChildImplicit () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml1:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="objInParent" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>; 
    	var parent:ApplicationContext = parseForContext2("obj", xml1, true);  	
    	var xml2:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassD" autowire="by-type"/>
    		</factory>
    	</application-context>; 
    	var child:ApplicationContext = parseForContext2("obj2", xml2);  	
    	assertEquals("Expected parent-child relationship", parent, child.parent);
    	assertStrictlyEquals("Expecting 2 objects in context", 2, child.objectCount);
    	var obj:Object = child.getObject("refProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassD));
    	var classD:ClassD = obj as ClassD;
    	assertTrue("Unexpected property value", (classD.ref is ClassB));		
	}
	
	public function testParentChildExplicit () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml1:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="objInParent" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>; 
    	var parent:ApplicationContext = parseForContext2("obj", xml1);  	
    	var xml2:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassD" autowire="by-type"/>
    		</factory>
    	</application-context>; 
    	var child:ApplicationContext = parseForContext2("obj2", xml2, false, false, parent);  	
    	assertEquals("Expected parent-child relationship", parent, child.parent);
    	assertStrictlyEquals("Expecting 2 objects in context", 2, child.objectCount);
    	var obj:Object = child.getObject("refProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassD));
    	var classD:ClassD = obj as ClassD;
    	assertTrue("Unexpected property value", (classD.ref is ClassB));		
	}
	
	public function testUseVariableFromOtherContextXml () : void {
		assertNull("root must be null", ApplicationContext.root);
		var xml1:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<setup>
		       <expressions>
		           <variable name="test"><uint>37</uint></variable>
		       </expressions>
		    </setup>
    	</application-context>; 
    	var xml2:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
				<object id="classA" type="org.spicefactory.parsley.config.testmodel.ClassA">
					<property name="uintProp" value="${test}"/>
				</object>
			</factory>
    	</application-context>; 
    	var prepare:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(xml2);
    	};
    	var context:ApplicationContext = parseForContext2("var", xml1, false, false, null, prepare);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	var obj:Object = context.getObject("classA");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertEquals("Unexpected property value", 37, classA.uintProp);	
	}
	
	public function testIncludeFiles () : void {
		var f:Function = addAsync(onIncludeTest, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("include");
		parser.addFile("testInclude2.xml");
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onIncludeTest (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Expecting 2 objects in context", 2, context.objectCount);
    	var obj:Object = context.getObject("classD");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassD", (obj is ClassD));
    	var classD:ClassD = obj as ClassD;
    	assertTrue("Unexpected property value", (classD.ref is ClassB));	
	}
	
	public function testFileNotFound () : void {
		var f:Function = addAsync(onFileNotFoundTest, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("include");
		parser.addFile("does-not-exist.xml");
		parser.addEventListener(ErrorEvent.ERROR, f);
		parser.start();
	}
	
	private function onFileNotFoundTest (event:ErrorEvent) : void {
		/* test passed */
	}
	
	public function testMergeVariables () : void {
		var f:Function = addAsync(onMergeVariables, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("mergeVariables");
		parser.addFile("testExpression2.xml");
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onMergeVariables (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 1, context.objectCount);
    	var obj:Object = context.getObject("classA");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertEquals("Unexpected property value", 34, classA.uintProp);	
    	assertEquals("Unexpected property value", "variable", classA.stringProp);	
	}
	
	
}

}