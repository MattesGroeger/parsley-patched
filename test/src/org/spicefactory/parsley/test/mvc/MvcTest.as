package org.spicefactory.parsley.test.mvc {
	
	
import flash.events.Event;
import flash.events.EventDispatcher;

import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.mvc.ApplicationEvent;
import org.spicefactory.parsley.mvc.EventSource;
import org.spicefactory.parsley.mvc.FrontController;
import org.spicefactory.parsley.namespaces.mvc.MvcNamespaceXml;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;

public class MvcTest extends ApplicationContextParserTest {
	

	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
		
	public function testActionRegistrations () : void {
		var action1:MockAction = new MockAction();
		var action2:MockAction = new MockAction();
		var action3:MockAction = new MockAction();
		var action4:MockAction = new MockAction();
		
		FrontController.root.registerAction(action1); // global action
		FrontController.root.registerAction(action2, MockEvent);
		FrontController.root.registerAction(action3, MockEvent, "eventType1");
		FrontController.root.registerAction(action4, null, "eventType2");
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);
	}
	
	public function testActionDelegateRegistrations () : void {
		var action1:MockAction = new MockAction();
		var action2:MockAction = new MockAction();
		var action3:MockAction = new MockAction();
		var action4:MockAction = new MockAction();
		
		FrontController.root.registerActionDelegate(action1.delegatedExecute); // global action
		FrontController.root.registerActionDelegate(action2.delegatedExecute, MockEvent);
		FrontController.root.registerActionDelegate(action3.delegatedExecute, MockEvent, "eventType1");
		FrontController.root.registerActionDelegate(action4.delegatedExecute, null, "eventType2");
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.delegateExecutionCount);
		assertEquals("Unexpected event count", 2, action2.delegateExecutionCount);
		assertEquals("Unexpected event count", 1, action3.delegateExecutionCount);
		assertEquals("Unexpected event count", 2, action4.delegateExecutionCount);		
	}
	
	public function testInterceptorRegistrations () : void {
		var controller:FrontController = new FrontController();
		
		var action:MockAction = new MockAction();
		controller.registerAction(action); // global action
		
		var ic1:MockInterceptor = new MockInterceptor();
		var ic2:MockInterceptor = new MockInterceptor();
		var ic3:MockInterceptor = new MockInterceptor();
		var ic4:MockInterceptor = new MockInterceptor();
		
		controller.registerInterceptor(ic1); // global interceptor
		controller.registerInterceptor(ic2, MockEvent);
		controller.registerInterceptor(ic3, MockEvent, "eventType1");
		controller.registerInterceptor(ic4, null, "eventType2");
		
		controller.dispatchEvent(new MockEvent("eventType1"));
		controller.dispatchEvent(new MockEvent("eventType2"));
		controller.dispatchEvent(new ApplicationEvent("eventType1"));
		controller.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected execution count", 4, ic1.executionCount);
		assertEquals("Unexpected execution count", 2, ic2.executionCount);
		assertEquals("Unexpected execution count", 1, ic3.executionCount);
		assertEquals("Unexpected execution count", 1, ic4.executionCount);	
		
		assertEquals("Unexpected execution count", 2, action.executionCount);	
	}
	
	public function testEventSourceRegistrations () : void {
		var controller:FrontController = new FrontController();
		
		var dispatcher:EventDispatcher = new EventDispatcher();
		var source:EventSource = new EventSource(dispatcher, transformEvent, ["e1", "e2", "e3", "e4"]);
		controller.registerEventSource(source);
		
		var action1:MockAction = new MockAction();
		var action2:MockAction = new MockAction();
		var action3:MockAction = new MockAction();
		var action4:MockAction = new MockAction();
		
		controller.registerAction(action1); // global action
		controller.registerAction(action2, MockEvent);
		controller.registerAction(action3, MockEvent, "eventType1");
		controller.registerAction(action4, null, "eventType2");
		
		dispatcher.dispatchEvent(new Event("e1"));
		dispatcher.dispatchEvent(new Event("e2"));
		dispatcher.dispatchEvent(new Event("e3"));
		dispatcher.dispatchEvent(new Event("e4"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);
	}
	
	private function transformEvent (event:Event) : ApplicationEvent {
		switch (event.type) {
			case "e1": return new MockEvent("eventType1");
			case "e2": return new MockEvent("eventType2");
			case "e3": return new ApplicationEvent("eventType1");
			case "e4": return new ApplicationEvent("eventType2");
		}
		return null;
	}
	
	public function testActionRemoval () : void {
		var controller:FrontController = new FrontController();
		
		var action1:MockAction = new MockAction();
		var action2:MockAction = new MockAction();
		var action3:MockAction = new MockAction();
		var action4:MockAction = new MockAction();
		
		controller.registerAction(action1); // global action
		controller.registerAction(action2, MockEvent);
		controller.registerAction(action3, MockEvent, "eventType1");
		controller.registerAction(action4, null, "eventType2");
		
		controller.dispatchEvent(new MockEvent("eventType1"));
		controller.dispatchEvent(new MockEvent("eventType2"));
		controller.dispatchEvent(new ApplicationEvent("eventType1"));
		controller.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);		
		
		controller.unregisterAction(action1); // global action
		controller.unregisterAction(action2, MockEvent);
		controller.unregisterAction(action3, MockEvent, "eventType1");
		controller.unregisterAction(action4, null, "eventType2");
		
		controller.dispatchEvent(new MockEvent("eventType1"));
		controller.dispatchEvent(new MockEvent("eventType2"));
		controller.dispatchEvent(new ApplicationEvent("eventType1"));
		controller.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);
	}
	
	public function testActionTags () : void {
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
    		<factory>
    		    <object id="action1" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action/>
    		    </object> 
    		    <object id="action2" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action3" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-name="eventType1" event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action4" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-name="eventType2"/>
    		    </object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 4, context.objectCount);
		
		var action1:MockAction = MockAction(context.getObject("action1"));
		var action2:MockAction = MockAction(context.getObject("action2"));
		var action3:MockAction = MockAction(context.getObject("action3"));
		var action4:MockAction = MockAction(context.getObject("action4"));
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);
	}
	
	public function testActionDelegateTags () : void {
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
			<factory>
    		    <object id="action1" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action method="delegatedExecute"/>
    		    </object> 
    		    <object id="action2" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action method="delegatedExecute" event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action3" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action method="delegatedExecute" event-name="eventType1" 
    		    		event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action4" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action method="delegatedExecute" event-name="eventType2"/>
    		    </object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 4, context.objectCount);
		
		var action1:MockAction = MockAction(context.getObject("action1"));
		var action2:MockAction = MockAction(context.getObject("action2"));
		var action3:MockAction = MockAction(context.getObject("action3"));
		var action4:MockAction = MockAction(context.getObject("action4"));
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected event count", 4, action1.delegateExecutionCount);
		assertEquals("Unexpected event count", 2, action2.delegateExecutionCount);
		assertEquals("Unexpected event count", 1, action3.delegateExecutionCount);
		assertEquals("Unexpected event count", 2, action4.delegateExecutionCount);		
	}
	
	public function testInterceptorTags () : void {
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
			<factory>
				<object id="action" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action/>
    		    </object>
    		    <object id="ic1" lazy="false" type="org.spicefactory.parsley.test.mvc.MockInterceptor">
    		    	<mvc:interceptor/>
    		    </object> 
    		    <object id="ic2" lazy="false" type="org.spicefactory.parsley.test.mvc.MockInterceptor">
    		    	<mvc:interceptor event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="ic3" lazy="false" type="org.spicefactory.parsley.test.mvc.MockInterceptor">
    		    	<mvc:interceptor event-name="eventType1" 
    		    		event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="ic4" lazy="false" type="org.spicefactory.parsley.test.mvc.MockInterceptor">
    		    	<mvc:interceptor event-name="eventType2"/>
    		    </object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 5, context.objectCount);
		
		var action:MockAction = MockAction(context.getObject("action"));
		
		var ic1:MockInterceptor = MockInterceptor(context.getObject("ic1"));
		var ic2:MockInterceptor = MockInterceptor(context.getObject("ic2"));
		var ic3:MockInterceptor = MockInterceptor(context.getObject("ic3"));
		var ic4:MockInterceptor = MockInterceptor(context.getObject("ic4"));
		
		FrontController.root.dispatchEvent(new MockEvent("eventType1"));
		FrontController.root.dispatchEvent(new MockEvent("eventType2"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType1"));
		FrontController.root.dispatchEvent(new ApplicationEvent("eventType2"));
		
		assertEquals("Unexpected execution count", 4, ic1.executionCount);
		assertEquals("Unexpected execution count", 2, ic2.executionCount);
		assertEquals("Unexpected execution count", 1, ic3.executionCount);
		assertEquals("Unexpected execution count", 1, ic4.executionCount);	
		
		assertEquals("Unexpected execution count", 2, action.executionCount);	
	}
	
	public function testEventSourceTags () : void {
		var x:EventTransformer;
		var c:FrontController = new FrontController(true);
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:mvc="http://www.spicefactory.org/parsley/1.0/mvc"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/mvc http://www.spicefactory.org/parsley/schema/1.0/parsley-mvc.xsd"
			>
    		<factory>
    		    <object id="transformer" type="org.spicefactory.parsley.test.mvc.EventTransformer"/>
    		    <object id="dispatcher" type="flash.events.EventDispatcher">
    		        <mvc:event-source event-types="e1,e2,e3,e4" 
    		        	transformer-object="transformer" transformer-method="transform"/>
    		    </object>
    		    <object id="action1" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action/>
    		    </object> 
    		    <object id="action2" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action3" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-name="eventType1" event-class="org.spicefactory.parsley.test.mvc.MockEvent"/>
    		    </object>
    		    <object id="action4" lazy="false" type="org.spicefactory.parsley.test.mvc.MockAction">
    		    	<mvc:action event-name="eventType2"/>
    		    </object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(MvcNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("mvc", xml, false, false, null, f);
		assertEquals("Unexpected object count", 6, context.objectCount);
		
		var action1:MockAction = MockAction(context.getObject("action1"));
		var action2:MockAction = MockAction(context.getObject("action2"));
		var action3:MockAction = MockAction(context.getObject("action3"));
		var action4:MockAction = MockAction(context.getObject("action4"));
		
		var dispatcher:EventDispatcher = EventDispatcher(context.getObject("dispatcher"));
		
		dispatcher.dispatchEvent(new Event("e1"));
		dispatcher.dispatchEvent(new Event("e2"));
		dispatcher.dispatchEvent(new Event("e3"));
		dispatcher.dispatchEvent(new Event("e4"));
		
		assertEquals("Unexpected event count", 4, action1.executionCount);
		assertEquals("Unexpected event count", 2, action2.executionCount);
		assertEquals("Unexpected event count", 1, action3.executionCount);
		assertEquals("Unexpected event count", 2, action4.executionCount);
	}
	
	
	
}

}