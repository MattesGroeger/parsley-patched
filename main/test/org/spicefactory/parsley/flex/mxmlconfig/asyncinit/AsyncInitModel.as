package org.spicefactory.parsley.flex.mxmlconfig.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class AsyncInitModel extends EventDispatcher {
	
	
	public static var instance:AsyncInitModel;
	
	
	function AsyncInitModel () {
		if (instance != null) {
			throw new IllegalStateError("Class should only be instantiated once");
		}
		instance = this;
	}
	
	
}
}
