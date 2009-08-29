package org.spicefactory.parsley.core.view {
import flash.display.DisplayObject;

/**
 * @author Jens Halm
 */
public interface ViewManager {
	
	
	function addViewRoot (view:DisplayObject) : void;

	function removeViewRoot (view:DisplayObject) : void;
	
	function get autoRemove () : Boolean;
	
	function set autoRemove (value:Boolean) : void;
	
	
}
}
