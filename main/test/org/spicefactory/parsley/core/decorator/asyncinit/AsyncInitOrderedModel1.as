package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

[AsyncInit(order=1)]
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
