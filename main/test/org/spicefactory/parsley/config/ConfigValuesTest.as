package org.spicefactory.parsley.config {

import flash.geom.Rectangle;

import org.spicefactory.lib.util.collection.List;
import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.config.testmodel.ClassB;
import org.spicefactory.parsley.config.testmodel.ClassD;
import org.spicefactory.parsley.config.testmodel.RectangleConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;	
	
public class ConfigValuesTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	
	private function createContextXML (objId:String, propNode:XML) : XML {
		return <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id={objId} type="org.spicefactory.parsley.config.testmodel.ClassA">
    				{propNode}
    			</object>
    		</factory>
    	</application-context>;  
	}
		
		
	public function testNullProperty () : void {
		var xml:XML = <property name="nullProp"><null/></property>;
    	parseForSingleObject("nullProp", createContextXML("nullProp", xml), onTestNullProperty, ClassA);
	}
	
	private function onTestNullProperty (obj:ClassA) : void {
		assertNull("Expected null propery value", obj.nullProp);
	}
		
    public function testStringProperty1 () : void {
    	var xml:XML = <property name="stringProp" value="Astring"/>;
    	parseForSingleObject("stringProp", createContextXML("stringProp", xml), onTestStringProperty, ClassA);
    }
    
    public function testStringProperty2 () : void {
    	var xml:XML = <property name="stringProp">
    				      <string>Astring</string>
    				  </property>;
    	parseForSingleObject("stringProp", createContextXML("stringProp", xml), onTestStringProperty, ClassA);  	
    }
    
    private function onTestStringProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.stringProp, "Astring");
    } 
    
    
    public function testUintProperty () : void {
    	var xml:XML = <property name="uintProp" value="7"/>;  
    	parseForSingleObject("uintProp", createContextXML("uintProp", xml), onTestUintProperty, ClassA);
    }
    
    private function onTestUintProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.uintProp, 7);
    } 
    
    
    public function testIntProperty () : void {
    	var xml:XML = <property name="intProp" value="-7"/>;  
    	parseForSingleObject("intProp", createContextXML("intProp", xml), onTestIntProperty, ClassA); 	
    }
    
    private function onTestIntProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.intProp, -7);
    } 
    
    
    public function testNumberProperty () : void {
    	var xml:XML = <property name="numberProp" value="7.5"/>;  
    	parseForSingleObject("numberProp", createContextXML("numberProp", xml), onTestNumberProperty, ClassA);  	
    }
    
    private function onTestNumberProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.numberProp, 7.5);
    } 
    
    
    public function testBooleanTrueProperty () : void {
    	var xml:XML = <property name="booleanProp" value="true"/>;  
    	parseForSingleObject("trueProp", createContextXML("trueProp", xml), onTestBooleanTrueProperty, ClassA);  
    }
    
    private function onTestBooleanTrueProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.booleanProp, true);
    } 
    
    
    public function testBooleanFalseProperty () : void {
    	var xml:XML = <property name="booleanProp" value="false"/>;  
    	parseForSingleObject("falseProp", createContextXML("falseProp", xml), onTestBooleanFalseProperty, ClassA);   	
    }
    
    private function onTestBooleanFalseProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.booleanProp, false);
    }
    
    
    public function testClassProperty () : void {
    	var xml:XML = <property name="classProp" value="org.spicefactory.parsley.config.testmodel.ClassA"/>;  
    	parseForSingleObject("classProp", createContextXML("classProp", xml), onTestClassProperty, ClassA);  	
    }
    
    private function onTestClassProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.classProp, ClassA);
    }
    
    
    public function testDateProperty () : void {
    	var xml:XML = <property name="dateProp" value="1967-02-28 12:00:00"/>;  
    	parseForSingleObject("dateProp", createContextXML("dateProp", xml), onTestDateProperty, ClassA);   	
    }
    
    private function onTestDateProperty (obj:ClassA) : void {
    	var date:Date = obj.dateProp;
    	assertStrictlyEquals("Unexpected year value", date.fullYear, 1967);
    	assertStrictlyEquals("Unexpected month value", date.month, 1);
    	assertStrictlyEquals("Unexpected day value", date.date, 28);
    	assertStrictlyEquals("Unexpected hour value", date.hours, 12);
    	assertStrictlyEquals("Unexpected minute value", date.minutes, 0);
    	assertStrictlyEquals("Unexpected second value", date.seconds, 0);
    }   
    
    
    public function testInlineObjectProperty () : void {
    	var xml:XML = <property name="refProp">
    	                  <object type="org.spicefactory.parsley.config.testmodel.ClassB">
    	                      <property name="tempVar" value="-3"/>
    	                  </object>
    	              </property>;
    	parseForSingleObject("refProp", createContextXML("refProp", xml), onTestInlineObjectProperty, ClassA);
    }
    
    private function onTestInlineObjectProperty (obj:ClassA) : void {
    	assertTrue("Unexpected property value", (obj.refProp is ClassB));
    	assertStrictlyEquals("Unexpected property value for reference", obj.refProp.tempVar, -3);
    }
    
    
    public function testRefProperty () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="refProp" ref="classB"/>
    			</object>
    			<object id="classB" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForContext("refProp", xml, onTestRefProperty);    	
    }
    
    public function testRefChildNodeProperty () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="refProp">
    				    <object-ref id="classB"/>
    				</property>
    			</object>
    			<object id="classB" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForContext("refProp", xml, onTestRefProperty);    	
    }
    
    public function testAutowireByType () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassD" autowire="by-type"/>
    			<object id="classB" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForContext("refProp", xml, onTestRefProperty2);    	
    }
    
    public function testAutowireByName () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" type="org.spicefactory.parsley.config.testmodel.ClassD" autowire="by-name"/>
    			<object id="ref" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForContext("refProp", xml, onTestRefProperty2);    	
    }
    
    public function testIllegalAutowireByType () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="refProp" lazy="false" 
    				type="org.spicefactory.parsley.config.testmodel.ClassD" autowire="by-type"/>
    			<object id="refA" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    			<object id="refB" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForContextError("refProp", xml);    	
    }
    
    private function onTestRefProperty (context:ApplicationContext) : void {
    	assertStrictlyEquals("Expecting 2 objects in context", 2, context.objectCount);
    	var obj:Object = context.getObject("refProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	assertTrue("Unexpected property value", (classA.refProp is ClassB));
    }   
    
	private function onTestRefProperty2 (context:ApplicationContext) : void {
    	assertStrictlyEquals("Expecting 2 objects in context", 2, context.objectCount);
    	var obj:Object = context.getObject("refProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassD));
    	var classD:ClassD = obj as ClassD;
    	assertTrue("Unexpected property value", (classD.ref is ClassB));
    }   
    
    
    public function testEmptyArrayProperty () : void {
    	var xml:XML = <property name="arrayProp">
						  <array/>    				
    				  </property>;  
    	parseForSingleObject("arrayProp", createContextXML("arrayProp", xml), onTestEmptyArrayProperty, ClassA);    	
    }
    
    private function onTestEmptyArrayProperty (obj:ClassA) : void {
    	var arr:Array = obj.arrayProp;
    	assertNotNull("Array property not set", arr);
    	assertStrictlyEquals("Unexpected Array length", arr.length, 0);
    }  
    
    
    public function testMixedArrayProperty () : void {
    	var xml:XML = <property name="arrayProp">
						  <array>
						      <string>Astring</string>
						      <uint>7</uint>
						  </array>    				
    				  </property>;  
    	parseForSingleObject("arrayProp", createContextXML("arrayProp", xml), onTestMixedArrayProperty, ClassA); 	
    }
    
    private function onTestMixedArrayProperty (obj:ClassA) : void {
    	var arr:Array = obj.arrayProp;
    	assertNotNull("Array property not set", arr);
    	assertStrictlyEquals("Unexpected Array length", arr.length, 2);
    	assertStrictlyEquals("Unexpected value for first array element", arr[0], "Astring");
    	assertStrictlyEquals("Unexpected value for second array element", arr[1], 7);
    } 
    

    public function testMixedListProperty () : void {
    	var xml:XML = <property name="listProp">
						  <list>
						      <boolean>true</boolean>
						      <uint>7</uint>
						  </list>    				
    				  </property>;  
    	parseForSingleObject("listProp", createContextXML("listProp", xml), onTestMixedListProperty, ClassA); 	
    }
    
    private function onTestMixedListProperty (obj:ClassA) : void {
    	var list:List = obj.listProp;
    	assertNotNull("Array property not set", list);
    	assertStrictlyEquals("Unexpected List length", list.getSize(), 2);
    	assertStrictlyEquals("Unexpected value for first List element", list.get(0), true);
    	assertStrictlyEquals("Unexpected value for second List element", list.get(1), 7);
    }   
    
    
    public function testSimpleStringArrayProperty () : void {
    	var xml:XML = <property name="arrayProp">
    	                  <string-array>A,B,C</string-array>
    	              </property>;
    	parseForSingleObject("arrayProp", createContextXML("arrayProp", xml), onTestSimpleStringArrayProperty, ClassA);
    }
    
    public function testCustomDelimiterArrayProperty () : void {
    	var xml:XML = <property name="arrayProp">
    	                  <string-array delimiter="!">A!B!C</string-array>
    	              </property>;
    	parseForSingleObject("arrayProp", createContextXML("arrayProp", xml), onTestSimpleStringArrayProperty, ClassA);
    }
    
    private function onTestSimpleStringArrayProperty (obj:ClassA) : void {
    	var arr:Array = obj.arrayProp;
    	assertNotNull("Array property not set", arr);
    	assertStrictlyEquals("Unexpected Array length", arr.length, 3);
    	assertStrictlyEquals("Unexpected value for first array element", arr[0], "A");
    	assertStrictlyEquals("Unexpected value for second array element", arr[1], "B");
    	assertStrictlyEquals("Unexpected value for third array element", arr[2], "C");
    }  
    
    
    public function testSimpleNumberArrayProperty () : void {
    	var xml:XML = <property name="arrayProp">
    	                  <number-array>4,7.5</number-array>
    	              </property>;
    	parseForSingleObject("arrayProp", createContextXML("arrayProp", xml), onTestSimpleNumberArrayProperty, ClassA);
    }
    
    private function onTestSimpleNumberArrayProperty (obj:ClassA) : void {
    	var arr:Array = obj.arrayProp;
    	assertNotNull("Array property not set", arr);
    	assertStrictlyEquals("Unexpected Array length", arr.length, 2);
    	assertStrictlyEquals("Unexpected value for first array element", arr[0], 4);
    	assertStrictlyEquals("Unexpected value for second array element", arr[1], 7.5);
    }  
    
    
    public function testStaticRefProperty () : void {
    	var xml:XML = <property name="stringProp">
                  <static-property-ref type="org.spicefactory.parsley.config.testmodel.ClassB" property="CONSTANT"/>
              </property>;
    	parseForSingleObject("staticRefProp", createContextXML("staticRefProp", xml), onTestStaticRefProperty, ClassA);
    }
    
    private function onTestStaticRefProperty (obj:ClassA) : void {
    	assertStrictlyEquals("Unexpected property value", obj.stringProp, "krautquark");
    }
    
    
    public function testCustomProperty () : void {
    	RectangleConverter; // just to compile class
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="customProp" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<property name="rectProp">
    				    <custom converter="rectConverter">0,100,640,480</custom>
    				</property>
    			</object>
    			<object id="rectConverter" type="org.spicefactory.parsley.config.testmodel.RectangleConverter"/>
    		</factory>
    	</application-context>;  
    	parseForContext("customProp", xml, onTestCustomProperty);    	
    }
    
    private function onTestCustomProperty (context:ApplicationContext) : void {
    	assertStrictlyEquals("Expecting 2 objects in context", 2, context.objectCount);
    	var obj:Object = context.getObject("customProp");
    	assertNotNull("Expecting Object instance", obj);
    	assertTrue("Expecting instance of ClassA", (obj is ClassA));
    	var classA:ClassA = obj as ClassA;
    	var rect:Rectangle = classA.rectProp;
    	assertNotNull("Expected Rectangle property value", rect);
    	assertEquals("Unexpected value for left property", 0, rect.left);
    	assertEquals("Unexpected value for top property", 100, rect.top);
    	assertEquals("Unexpected value for width property", 640, rect.width);
    	assertEquals("Unexpected value for height property", 480, rect.height);
    }
    
    
    public function testContextRefProperty () : void {
    	var xml:XML = <property name="contextProp">
    	                   <app-context/>
    	              </property>;
    	parseForSingleObject("contextProp", createContextXML("contextProp", xml), onTestContextRefProperty, ClassA);
    }
    
    private function onTestContextRefProperty (obj:ClassA) : void {
    	assertTrue("Unexpected property type", (obj.contextProp is ApplicationContext));
    	var context:ApplicationContext = obj.contextProp as ApplicationContext;
    	assertStrictlyEquals("Unexpected context name", context.name, "contextProp");
    }
    
    
    public function testApplicationContextAware () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
    		<factory>
    			<object id="contextAware" type="org.spicefactory.parsley.config.testmodel.ClassB"/>
    		</factory>
    	</application-context>;  
    	parseForSingleObject("contextAware", xml, onTestApplicationContextAware, ClassB);    
    }
    
    private function onTestApplicationContextAware (obj:ClassB) : void {
    	assertTrue("Unexpected property type", (obj.applicationContext is ApplicationContext));
    	var context:ApplicationContext = obj.applicationContext as ApplicationContext;
    	assertStrictlyEquals("Unexpected context name", context.name, "contextAware");
    }
    
    

    
    
}

}