package org.spicefactory.parsley.flex.mxmlconfig.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class AsyncInitOrderedModel2 extends EventDispatcher {
	
	
	public static var instance:AsyncInitOrderedModel2;
	
	
	function AsyncInitOrderedModel2 () {
		if (instance != null) {
			throw new IllegalStateError("Class should only be instantiated once");
		}
		instance = this;
	}
	
	
}
}
