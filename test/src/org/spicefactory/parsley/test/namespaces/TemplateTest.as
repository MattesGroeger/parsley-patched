package org.spicefactory.parsley.test.namespaces {
	
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.config.testmodel.Book;
import org.spicefactory.parsley.config.testmodel.Catalog;
import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.config.testmodel.ClassE;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;

public class TemplateTest extends ApplicationContextParserTest {
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	public function testSimpleFactoryTemplate () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest">
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
	
	public function testFactoryProcessorChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:test="urn:parsley.unitTest">
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
	
	public function testProcessorNestedProcessorChildren () : void {
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:test="urn:parsley.unitTest">
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
			xmlns:store="urn:parsley.unitTest.store">
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
	
	
}

}