package org.spicefactory.parsley.flash.binding {
import org.spicefactory.parsley.binding.model.Animal;
import org.spicefactory.parsley.binding.model.AnimalHolder;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

/**
 * @author Jens Halm
 */
public class FlashAnimal extends AnimalHolder implements IEventDispatcher {
	
	
	private var dispatcher:EventDispatcher;
	
	function FlashAnimal () {
		dispatcher = new EventDispatcher(this);
	}
	
	public override function get value () : Animal {
		return super.value;
	}
	
	public override function set value (value:Animal) : void {
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
