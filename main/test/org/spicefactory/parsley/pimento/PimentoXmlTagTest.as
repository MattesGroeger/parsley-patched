package org.spicefactory.parsley.pimento {
import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.parsley.cinnamon.CinnamonXmlSupport;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.xml.XmlContextTestBase;
import org.spicefactory.pimento.config.PimentoConfig;
import org.spicefactory.pimento.service.EntityManager;
import org.spicefactory.pimento.service.impl.PimentoInvocationHandler;

public class PimentoXmlTagTest extends XmlContextTestBase {

	
	CinnamonXmlSupport.initialize();
	PimentoXmlSupport.initialize();
	
	
	public function testCinnamonServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var config:XML = <objects 
			xmlns="http://www.spicefactory.org/parsley"
			xmlns:cinnamon="http://www.spicefactory.org/parsley/cinnamon"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd http://www.spicefactory.org/parsley/cinnamon http://www.spicefactory.org/parsley/schema/2.0/parsley-cinnamon.xsd"
			>
			<cinnamon:channel 
			    id="mainChannel"
			    url="http://localhost/test/service/"
			    timeout="3000"
			/>
			<cinnamon:service
			    name="echoService"
			    type="org.spicefactory.parsley.pimento.EchoServiceImpl"
			/>
    	</objects>;
		var context:Context = getContext(config);
		checkState(context);
		var service:EchoService = context.getObjectByType(EchoService, true) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertNotNull("Expected proxy instance", proxy);
		assertEquals("Unexpected service URL", "http://localhost/test/service/", proxy.channel.serviceUrl);
	}
	
	public function testPimentoServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var configXml:XML = <objects 
			xmlns="http://www.spicefactory.org/parsley"
			xmlns:pimento="http://www.spicefactory.org/parsley/pimento"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd http://www.spicefactory.org/parsley/pimento http://www.spicefactory.org/parsley/schema/2.0/parsley-pimento.xsd"
			>
			<pimento:config 
			    url="http://localhost/test/service/"
			    timeout="3000"
			/>
			<pimento:service
			    name="echoService"
			    type="org.spicefactory.parsley.pimento.EchoServiceImpl"
			/>
    	</objects>;
		var context:Context = getContext(configXml);
		checkState(context);
		
		var service:EchoService = context.getObjectByType(EchoService, true) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertNotNull("Expected proxy instance", proxy);
		assertEquals("Unexpected service URL", "http://localhost/test/service/", proxy.channel.serviceUrl);
		assertTrue("Expected PimentoInvocationHandler", (proxy.invocationHandler is PimentoInvocationHandler));
		
		var config:PimentoConfig = context.getObjectByType(PimentoConfig, true) as PimentoConfig;
		assertEquals("Unexpected config URL", "http://localhost/test/service/", config.serviceUrl);
		assertEquals("Unexpected timeout", 3000, config.defaultTimeout);
		
		var entityManager:EntityManager = context.getObjectByType(EntityManager, true) as EntityManager;
		var emProxy:ServiceProxy = ServiceProxy.forService(entityManager);
		assertNotNull("Expected proxy instance", emProxy);
	}
	
	
}

}