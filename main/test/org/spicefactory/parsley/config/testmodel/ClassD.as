package org.spicefactory.parsley.config.testmodel {
	import flash.events.Event;
	
	
public class ClassD {
	
	private var _ref:ClassB;
	
	private var _events:Array = new Array();
	
	
	function ClassD () {
	}
	
	
	public function get ref () : ClassB {
		return _ref;
	}
	
	public function set ref (value:ClassB) : void {
		_ref = value;
	}
	
	
	public function handleEvent (event:Event) : void {
		_events.push(event);
	}
	
	public function getAllEvents () : Array {
		return _events.concat();
	}
	
	
}

}