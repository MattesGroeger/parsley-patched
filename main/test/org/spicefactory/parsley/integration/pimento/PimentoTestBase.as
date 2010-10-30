package org.spicefactory.parsley.integration.pimento {
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.flexunit.assertThat;
	import org.spicefactory.parsley.integration.pimento.model.EchoServiceImpl;
	import org.spicefactory.parsley.integration.pimento.model.EchoService;
import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.pimento.config.PimentoConfig;
import org.spicefactory.pimento.service.EntityManager;

public class PimentoTestBase {


	private static const URL:String = "http://localhost:8080/Pimento_Server/cinnamon/";

	
	[Test]
	public function cinnamonServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var context:Context = cinnamonContext;
		var service:EchoService = context.getObjectByType(EchoService) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertThat(proxy, notNullValue());
		assertThat(proxy.channel.serviceUrl, equalTo(URL));
	}
	
	[Test]
	public function pimentoServiceConfig () : void {
		var c:Class = EchoServiceImpl;
		var context:Context = pimentoContext;
		
		var service:EchoService = context.getObjectByType(EchoService) as EchoService;
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		assertThat(proxy, notNullValue());
		assertThat(proxy.channel.serviceUrl, equalTo(URL));
		
		var config:PimentoConfig = context.getObjectByType(PimentoConfig) as PimentoConfig;
		assertThat(config.serviceUrl, equalTo(URL));
		assertThat(config.defaultTimeout, equalTo(3000));
		
		var entityManager:EntityManager = context.getObjectByType(EntityManager) as EntityManager;
		assertThat(ServiceProxy.forService(entityManager), notNullValue());
	}
	
	public function get pimentoContext () : Context {
		throw new AbstractMethodError();
	}
	
	public function get cinnamonContext () : Context {
		throw new AbstractMethodError();
	}
	
	
}

}