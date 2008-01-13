package org.spicefactory.parsley.test.namespaces {
	
import org.spicefactory.cinnamon.client.ServiceEvent;
import org.spicefactory.cinnamon.client.ServiceProxy;
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.namespaces.cinnamon.CinnamonNamespaceXml;

public class CinnamonTest extends ApplicationContextParserTest {
	

	public function testServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/context-ns/1.0/"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
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
			trace("add config to parser");    		
    		parser.addXml(CinnamonNamespaceXml.config);
    	}
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
			xmlns="http://www.spicefactory.org/parsley/context-ns/1.0/"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
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
			trace("add config to parser");    		
    		parser.addXml(CinnamonNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("cinnamon", xml, false, false, null, f);
		assertEquals("Unexpected object count", 3, context.objectCount);
		var service:EchoService = EchoService(context.getObject("echoService"));
		assertNotNull("Expected service instance", service);
		var listener:CinnamonListener = CinnamonListener(context.getObject("proxyListener"));
		assertNotNull("Expected listener instance", listener);	
		service.echo(null);
		service.echo(null);
		trace(" has listener ? " + ServiceProxy.forService(service).hasEventListener("invoke"));
		assertEquals("Unexpected event count", 2, listener.proxyEventCount);
	}
	
	public function testOperationListener () : void {
		var c:Class = EchoServiceImpl;
		c = MockChannel;
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/context-ns/1.0/"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/1.0/cinnamon"
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
			trace("add config to parser");    		
    		parser.addXml(CinnamonNamespaceXml.config);
    	}
		var context:ApplicationContext = parseForContext2("cinnamon", xml, false, false, null, f);
		assertEquals("Unexpected object count", 3, context.objectCount);
		var service:EchoService = EchoService(context.getObject("echoService"));
		assertNotNull("Expected service instance", service);
		var listener:CinnamonListener = CinnamonListener(context.getObject("proxyListener"));
		assertNotNull("Expected listener instance", listener);	
		service.echo(null);
		service.echo(null);
		trace(" has listener ? " + ServiceProxy.forService(service).hasEventListener("invoke"));
		assertEquals("Unexpected operation event count", 2, listener.operationEventCount);
		assertEquals("Unexpected proxy event count", 0, listener.proxyEventCount);
	}
	
	
}

}