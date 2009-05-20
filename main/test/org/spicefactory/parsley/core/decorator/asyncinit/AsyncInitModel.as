package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.lib.errors.IllegalStateError;

import flash.events.EventDispatcher;

[AsyncInit]
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
