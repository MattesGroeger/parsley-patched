package org.spicefactory.parsley.core.messaging {

/**
 * @author Jens Halm
 */
public class TestMessageDispatcher {
	
	
	private var _dispatcher:Function;
	
	
	[MessageDispatcher]
	public function set dispatcher (disp:Function) : void {
		_dispatcher = disp;
	}
	
	
	public function dispatchMessage (message:Object) : void {
		_dispatcher(message);
	}
	
	
}
}
