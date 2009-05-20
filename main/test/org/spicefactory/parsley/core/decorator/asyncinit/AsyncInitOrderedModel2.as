package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

[AsyncInit(order=2, completeEvent="customComplete", errorEvent="errorComplete")]
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
