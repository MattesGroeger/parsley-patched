package org.spicefactory.parsley.test.namespaces {
import org.spicefactory.cinnamon.client.ServiceProxy;
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.context.ns.context_internal;
import org.spicefactory.parsley.namespaces.cinnamon.CinnamonNamespaceXml;	

//import org.spicefactory.parsley.context.ns.context_internal;

public class CinnamonTagsTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	
	public function testServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/cinnamon http://www.spicefactory.org/parsley/schema/1.0/parsley-cinnamon.xsd"
			>
    		<factory>
    			<cinnamon:channel 
				    id="mainChannel"
				    url="http://localhost/test/service/"
				    timeout="3000"
				/>
				<cinnamon:service
				    id="echoService"
				    type="org.spicefactory.parsley.test.namespaces.EchoServiceImpl"
				    channel="mainChannel"
				/>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(CinnamonNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("cinnamon", xml, false, false, null, f);
		assertEquals("Unexpected object count", 2, context.objectCount);
		var service:EchoService = EchoService(context.getObject("echoService"));
		assertNotNull("Expected service instance", service);
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertNotNull("Expected proxy instance", proxy);
		assertEquals("Unexpected service URL", "http://localhost/test/service/", proxy.channel.serviceUrl);
	}
	
	public function testProxyListener () : void {
		var c:Class = EchoServiceImpl;
		c = MockChannel;
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/cinnamon http://www.spicefactory.org/parsley/schema/1.0/parsley-cinnamon.xsd"
			>
    		<factory>
    			<cinnamon:channel 
				    id="mockChannel"
				    type="org.spicefactory.parsley.test.namespaces.MockChannel"
				    url="http://localhost/test/service/"
				    timeout="3000"
				/>
				<cinnamon:service
				    id="echoService"
				    type="org.spicefactory.parsley.test.namespaces.EchoServiceImpl"
				    channel="mockChannel"
				/>
				<object id="proxyListener" type="org.spicefactory.parsley.test.namespaces.CinnamonListener">
					<cinnamon:proxy-listener service="echoService" event-type="invoke" method="handleProxyEvent"/>
				</object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(CinnamonNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("cinnamon", xml, false, false, null, f);
		assertEquals("Unexpected object count", 3, context.objectCount);
		var service:EchoService = EchoService(context.getObject("echoService"));
		assertNotNull("Expected service instance", service);
		var listener:CinnamonListener = CinnamonListener(context.getObject("proxyListener"));
		assertNotNull("Expected listener instance", listener);	
		service.echo(null);
		service.echo(null);
		assertEquals("Unexpected event count", 2, listener.proxyEventCount);
	}
	
	public function testOperationListener () : void {
		var c:Class = EchoServiceImpl;
		c = MockChannel;
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/cinnamon http://www.spicefactory.org/parsley/schema/1.0/parsley-cinnamon.xsd"
			>
    		<factory>
    			<cinnamon:channel 
				    id="mockChannel"
				    type="org.spicefactory.parsley.test.namespaces.MockChannel"
				    url="http://localhost/test/service/"
				    timeout="3000"
				/>
				<cinnamon:service
				    id="echoService"
				    type="org.spicefactory.parsley.test.namespaces.EchoServiceImpl"
				    channel="mockChannel"
				/>
				<object id="proxyListener" type="org.spicefactory.parsley.test.namespaces.CinnamonListener">
					<cinnamon:operation-listener 
						service="echoService" operation="echo" event-type="invoke" method="handleOperationEvent"/>
				</object>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(CinnamonNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("cinnamon", xml, false, false, null, f);
		assertEquals("Unexpected object count", 3, context.objectCount);
		var service:EchoService = EchoService(context.getObject("echoService"));
		assertNotNull("Expected service instance", service);
		var listener:CinnamonListener = CinnamonListener(context.getObject("proxyListener"));
		assertNotNull("Expected listener instance", listener);	
		service.echo(null);
		service.echo(null);
		assertEquals("Unexpected operation event count", 2, listener.operationEventCount);
		assertEquals("Unexpected proxy event count", 0, listener.proxyEventCount);
	}
	
	
}

}