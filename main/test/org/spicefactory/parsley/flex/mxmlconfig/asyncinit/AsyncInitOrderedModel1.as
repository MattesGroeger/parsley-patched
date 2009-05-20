package org.spicefactory.parsley.flex.mxmlconfig.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class AsyncInitOrderedModel1 extends EventDispatcher {
	
	
	public static var instance:AsyncInitOrderedModel1;
	
	
	function AsyncInitOrderedModel1 () {
		if (instance != null) {
			throw new IllegalStateError("Class should only be instantiated once");
		}
		instance = this;
	}
	
	
}
}
