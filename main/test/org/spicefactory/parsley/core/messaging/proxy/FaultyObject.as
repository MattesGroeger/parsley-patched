package org.spicefactory.parsley.core.messaging.proxy {

/**
 * @author Jens Halm
 */
public class FaultyObject {
	
	
	[Init]
	public function init () : void {
		throw new Error("This init method is broken on purpose");
	}
	
	
}
}
