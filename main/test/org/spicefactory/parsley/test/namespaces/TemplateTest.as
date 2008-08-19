package org.spicefactory.parsley.test.namespaces {
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.config.testmodel.Book;
import org.spicefactory.parsley.config.testmodel.Catalog;
import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.config.testmodel.ClassE;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.ns.context_internal;
import org.spicefactory.parsley.mvc.ApplicationEvent;
import org.spicefactory.parsley.mvc.FrontController;
import org.spicefactory.parsley.namespaces.mvc.MvcNamespaceXml;
import org.spicefactory.parsley.test.mvc.MockAction;
import org.spicefactory.parsley.test.mvc.MockEvent;	

//import org.spicefactory.parsley.context.ns.context_internal;

public class TemplateTest extends ApplicationContextParserTest {
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	public function testSimpleFactoryTemplate () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="foo"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA"/>
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
	}
	
	public function testTwoSingletonFactoryTemplateClients () : void {
		ClassA;
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="${@testid}"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA"/>
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test testid="foo1"/>
    			<test:test testid="foo2"/>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 2, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo1"));
    	assertTrue("Expected object in context", context.containsObject("foo2"));
    	var obj1a:Object = context.getObject("foo1");
    	var obj1b:Object = context.getObject("foo1");
    	var obj2a:Object = context.getObject("foo2");
    	var obj2b:Object = context.getObject("foo2");
    	assertEquals("Expected singleton object", obj1a, obj1b);
    	assertEquals("Expected singleton object", obj2a, obj2b);
    	assertFalse("Expected two distinct objects", (obj1a == obj2a));
	}
	
	public function testFactoryProcessorChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="foo"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA">
		    	        	    <property name="stringProp" value="${@client}"/>
		    	        	    <apply-children/>
							</object>		    	        	    
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test client="foo">
    			    <property name="intProp" value="5"/>
    			</test:test>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "foo", classA.stringProp);
    	assertEquals("Unexpected property value", 5, classA.intProp);
	}
	
	public function testFactoryArrayChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="foo"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA">
		    	        	    <property name="stringProp" value="${@client}"/>
		    	        	    <property name="arrayProp">
		    	        	        <array>
		    	        	    		<apply-children/>
		    	        	    		<string>D</string>
		    	        	    	</array>
		    	        	    </property>
							</object>		    	        	    
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test client="foo">
    			    <string>A</string>
    			    <string>B</string>
    			    <string>C</string>
    			</test:test>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "foo", classA.stringProp);
    	var arr:Array = classA.arrayProp;
    	assertNotNull("Expected Array property", arr);
    	assertEquals("Unexpected Array length", 4, arr.length);
    	assertEquals("Unexpected Array element", "A", arr[0]);
    	assertEquals("Unexpected Array element", "B", arr[1]);
    	assertEquals("Unexpected Array element", "C", arr[2]);
    	assertEquals("Unexpected Array element", "D", arr[3]);
	}
	
	public function testFactoryPropertyChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="foo"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA">
		    	        	    <property name="stringProp" value="${@client}"/>
		    	        	    <property name="intProp">
		    	        	    	<apply-children/>
		    	        	    </property>
							</object>		    	        	    
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test client="foo">
    			    <int>5</int>
    			</test:test>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "foo", classA.stringProp);
    	assertEquals("Unexpected property value", 5, classA.intProp);
	}
	
	public function testFactoryIllegalPropertyChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="foo"/>
		    	        	<object type="org.spicefactory.parsley.config.testmodel.ClassA">
		    	        	    <property name="stringProp" value="${@client}"/>
		    	        	    <property name="intProp">
		    	        	    	<apply-children/>
		    	        	    </property>
							</object>		    	        	    
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<test:test client="foo">
    			    <int>5</int>
    			    <int>5</int>
    			</test:test>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	try {
    		context.getObject("foo");
 		} catch (e:Error) {
			if (e is ConfigurationError) { 			
 				return;
 			}
 		}
    	fail("Expected ConfigurationError");
	}
	
	public function testSimpleProcessorTemplate () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <processor-template tag-name="test">
		    	        	<property name="stringProp" value="fromTemplate"/>
		    	        </processor-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<object id="foo" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<test:test/>
    			</object>
    		</factory>
    	</application-context>; 
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "fromTemplate", classA.stringProp);
	}
	
	public function testProcessorPropertyChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <processor-template tag-name="test">
		    	        	<property name="stringProp" value="${@value}"/>
		    	        	<property name="intProp">
		    	        	    <apply-children/>
		    	        	</property>
		    	        </processor-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<object id="foo" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<test:test value="fromClientTag">
    					<int>7</int>
    				</test:test>
    			</object>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "fromClientTag", classA.stringProp);
    	assertEquals("Unexpected property value", 7, classA.intProp);
	}
	
	public function testTwoProcessorTemplates () : void {
		var attribute:String = "${@value}";
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <processor-template tag-name="test">
		    	        	<init-method name="testMethodWithArg">
		    	        		<string>{attribute}</string>
		    	        	</init-method>
		    	        </processor-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<object id="foo" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<test:test value="A"/>
    				<test:test value="B"/>
    			</object>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	var args:Array = classA.testMethodArgs;
    	assertEquals("Unexpected number of arguments", 2, args.length);
    	assertEquals("Unexpected argument", "A", args[0]);
    	assertEquals("Unexpected argument", "B", args[1]);
	}
	
	public function testTwoProcessorTemplatesWithObjectRefs () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <processor-template tag-name="test">
		    	        	<init-method name="testMethodWithArg">
		    	        		<object-ref id="${@value}"/>
		    	        	</init-method>
		    	        </processor-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<object id="ref1" type="org.spicefactory.parsley.config.testmodel.ClassA"/> 
    			<object id="ref2" type="org.spicefactory.parsley.config.testmodel.ClassA"/> 
    			<object id="foo" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<test:test value="ref1"/>
    				<test:test value="ref2"/>
    			</object>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 3, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	var ref1:ClassA = ClassA(context.getObject("ref1"));
    	var ref2:ClassA = ClassA(context.getObject("ref2"));
    	var args:Array = classA.testMethodArgs;
    	assertEquals("Unexpected number of arguments", 2, args.length);
    	assertEquals("Unexpected argument", ref1, args[0]);
    	assertEquals("Unexpected argument", ref2, args[1]);
	}
	
	public function testProcessorNestedProcessorChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <processor-template tag-name="test">
		    	        	<property name="stringProp" value="${@value}"/>
		    	        	<property name="ref2Prop">
		    	        	    <object type="org.spicefactory.parsley.config.testmodel.ClassE">
		    	        	    	<apply-children/>
		    	        	    </object>
		    	        	</property>
		    	        </processor-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<object id="foo" type="org.spicefactory.parsley.config.testmodel.ClassA">
    				<test:test value="fromClientTag">
    					<property name="stringProp" value="classEProp"/>
    				</test:test>
    			</object>
    		</factory>
    	</application-context>;
    	var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("foo"));
    	var obj:Object = context.getObject("foo");
    	assertTrue("Unexpected type", (obj is ClassA));
    	var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected property value", "fromClientTag", classA.stringProp);
    	var ref:ClassE = classA.ref2Prop;
    	assertNotNull("Expected ClassE property", ref);
    	assertEquals("Unexpected property value", "classEProp", ref.stringProp);
	}
	
	public function testSameTagAsProcessorAndFactory () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:store="urn:parsley.unitTest.store" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd">
		    <setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest.store">
       
					    <factory-template tag-name="catalog">  
					        <factory-metadata id="${@id}"/>
					        <object type="org.spicefactory.parsley.config.testmodel.Catalog">
					            <apply-children/>
					        </object>
					    </factory-template> 
					    
					    <processor-template tag-name="book">
					        <init-method name="addBook">
					            <apply-factory-template/>
					        </init-method>
					    </processor-template>
					    
					    <factory-template tag-name="book">  
					        <factory-metadata id="${@id}"/>
					        <object type="org.spicefactory.parsley.config.testmodel.Book">
					            <property name="title" value="${@title}"/>
					            <property name="author" value="${@author}"/>
					            <property name="price" value="${@price}"/>
					        </object>
					    </factory-template>     
					    
					</namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    			<store:catalog id="mainCatalog">
				    <store:book title="The Fish an Me" author="Jeff Maritim" price="44.75"/> 
				    <store:book title="I'm Just Sleeping" author="Hank Weary" price="52.25"/> 
				</store:catalog>
    		</factory>
    	</application-context>;
		var context:ApplicationContext = parseForContext2("template", xml);  	
    	assertEquals("Unexpected object count", 1, context.objectCount);
    	assertTrue("Expected object in context", context.containsObject("mainCatalog"));
    	var obj:Object = context.getObject("mainCatalog");
    	assertTrue("Unexpected type", (obj is Catalog));
    	var catalog:Catalog = Catalog(obj);
    	var books:Array = catalog.getAllBooks();
    	assertEquals("Unexpected number of books", 2, books.length);
    	assertEquals("Unexpected author", "Jeff Maritim", Book(books[0]).author);
    	assertEquals("Unexpected author", "Hank Weary", Book(books[1]).author);
	}
	
	public function testCustomTagWithinTemplateClient () : void {
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
			<setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="${@id}"/>
		    	        	<object type="org.spicefactory.parsley.test.mvc.MockAction">
								<apply-children/>		    	        	
		    	        	</object>
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    		    <test:test id="foo">
    		    	<mvc:action/>
    		    </test:test> 
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 1, context.objectCount);
		
		var action:MockAction = MockAction(context.getObject("foo"));
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action.executionCount);
	}
	
	/*
	 * TODO - this fails 
	public function testCustomTagWithinTemplate () : void {
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
			<setup>
		    	<namespaces>
		    	    <namespace uri="urn:parsley.unitTest">
		    	        <factory-template tag-name="test">
		    	        	<factory-metadata id="${@id}"/>
		    	        	<object type="org.spicefactory.parsley.test.mvc.MockAction">
								<mvc:action/>		    	        	
		    	        	</object>
		    	        </factory-template>
		    	    </namespace>
		    	</namespaces>
		    </setup>
    		<factory>
    		    <test:test id="foo"/>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 1, context.objectCount);
		
		var action:MockAction = MockAction(context.getObject("foo"));
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action.executionCount);
	}
	 * 
	 */
	
	
}

}