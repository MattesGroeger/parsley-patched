package org.spicefactory.parsley.test.namespaces {
	import org.spicefactory.cinnamon.client.ServiceEvent;
	
	
public class CinnamonListener {
	
	
	private var _proxyEventCount:uint = 0;
	private var _operationEventCount:uint = 0;
	

	public function handleProxyEvent (event:ServiceEvent) : void {
		_proxyEventCount++;
	}
	
	public function handleOperationEvent (event:ServiceEvent) : void {
		_operationEventCount++;
	}
	
	public function get proxyEventCount () : uint {
		return _proxyEventCount;
	}
	
	public function get operationEventCount () : uint {
		return _operationEventCount;
	}
	
	
}

}