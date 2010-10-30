package org.spicefactory.parsley.testmodel {
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
