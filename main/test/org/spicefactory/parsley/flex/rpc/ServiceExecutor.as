package org.spicefactory.parsley.flex.rpc {
import org.spicefactory.parsley.messaging.messages.TestEvent;

import mx.rpc.AsyncToken;
import mx.rpc.remoting.RemoteObject;

/**
 * @author Jens Halm
 */
public class ServiceExecutor {
	
	
	[Inject]
	public var service:RemoteObject; 
	
	
	[Command(selector="test1")]
	public function executeWithResult (event:TestEvent) : AsyncToken {
		return service.getContactsByName("f");
	}
	
	
}
}
