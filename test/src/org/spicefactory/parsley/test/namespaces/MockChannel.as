package org.spicefactory.parsley.test.namespaces {
	
import org.spicefactory.cinnamon.client.NetConnectionServiceChannel;
import org.spicefactory.cinnamon.client.ServiceRequest;

public class MockChannel extends NetConnectionServiceChannel {
	
	
	private var _connected:Boolean = false;
	
	
	public override function get connected () : Boolean {
		return _connected;
	}
	
	public override function connect () : void {
		_connected = true;
	}
	
	public override function execute (request:ServiceRequest, resultHandler:Function, errorHandler:Function) : void {
		resultHandler(null);
	}
	
	
	
}

}