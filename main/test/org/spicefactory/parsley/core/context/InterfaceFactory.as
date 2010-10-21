package org.spicefactory.parsley.core.context {
import flash.display.Sprite;
import flash.events.IEventDispatcher;

/**
 * @author jenshalm
 */
public class InterfaceFactory {
	
	[Factory]
	public function createInstance () : IEventDispatcher {
		return new Sprite();
	}
	
}
}
