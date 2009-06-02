package org.spicefactory.parsley.pimento {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.xml.XmlContextTestBase;
import org.spicefactory.pimento.config.PimentoConfig;
import org.spicefactory.pimento.service.EntityManager;
import org.spicefactory.pimento.service.impl.PimentoInvocationHandler;

public class PimentoMxmlTagTest extends XmlContextTestBase {

	
	public function testCinnamonServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var context:Context = ActionScriptContextBuilder.build(CinnamonMxmlTagContainer);
		checkState(context);
		var service:EchoService = context.getObjectByType(EchoService) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertNotNull("Expected proxy instance", proxy);
		assertEquals("Unexpected service URL", "http://localhost/test/service/", proxy.channel.serviceUrl);
	}
	
	public function testPimentoServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var context:Context = ActionScriptContextBuilder.build(PimentoMxmlTagContainer);
		checkState(context);
		
		var service:EchoService = context.getObjectByType(EchoService) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertNotNull("Expected proxy instance", proxy);
		assertEquals("Unexpected service URL", "http://localhost/test/service/", proxy.channel.serviceUrl);
		assertTrue("Expected PimentoInvocationHandler", (proxy.invocationHandler is PimentoInvocationHandler));
		
		var config:PimentoConfig = context.getObjectByType(PimentoConfig) as PimentoConfig;
		assertEquals("Unexpected config URL", "http://localhost/test/service/", config.serviceUrl);
		assertEquals("Unexpected timeout", 3000, config.defaultTimeout);
		
		var entityManager:EntityManager = context.getObjectByType(EntityManager) as EntityManager;
		var emProxy:ServiceProxy = ServiceProxy.forService(entityManager);
		assertNotNull("Expected proxy instance", emProxy);
	}
	
	
}

}