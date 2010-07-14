package org.spicefactory.parsley.flash.binding {
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.IEventDispatcher;
import org.spicefactory.parsley.binding.model.Cat;
import org.spicefactory.parsley.binding.model.CatHolder;

/**
 * @author Jens Halm
 */
public class FlashCat extends CatHolder implements IEventDispatcher {
	
	
	private var dispatcher:EventDispatcher;
	
	function FlashCat () {
		dispatcher = new EventDispatcher(this);
	}

	public override function get value () : Cat {
		return super.value;
	}
	
	public override function set value (value:Cat) : void {
		super.value = value;
		dispatchEvent(new Event(Event.CHANGE));
	}

	public function dispatchEvent (event:Event):Boolean {
		return dispatcher.dispatchEvent(event);
	}
	
	public function hasEventListener (type:String):Boolean {
		return dispatcher.hasEventListener(type);
	}
	
	public function willTrigger (type:String):Boolean {
		return dispatcher.willTrigger(type);
	}
	
	public function removeEventListener (type:String, listener:Function, useCapture:Boolean = false):void {
		dispatcher.removeEventListener(type, listener);
	}
	
	public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
		dispatcher.addEventListener(type, listener);
	}
	
	
}
}
