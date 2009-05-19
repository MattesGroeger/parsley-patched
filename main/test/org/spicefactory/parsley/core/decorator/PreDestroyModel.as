package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class PreDestroyModel {
	
	
	private var _methodCalled:Boolean = false;
	
	
	[PreDestroy]
	public function dispose () : void {
		trace("PreDestroy called");
		_methodCalled = true;
	}
	
	public function get methodCalled () : Boolean {
		return _methodCalled;
	}
	
	
}
}
