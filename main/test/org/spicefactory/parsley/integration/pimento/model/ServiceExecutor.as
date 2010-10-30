package org.spicefactory.parsley.integration.pimento.model {
import org.spicefactory.cinnamon.service.ServiceRequest;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class ServiceExecutor {
	
	
	[Inject]
	public var service:EchoService; 
	
	
	[Command(selector="test1")]
	public function executeWithResult (event:TestEvent) : ServiceRequest {
		return service.echo(event.stringProp);
	}
	
	[Command(selector="test2")]
	public function executeWithError (event:TestEvent) : ServiceRequest {
		return service.echo(event.stringProp);
	}
	
	
}
}
