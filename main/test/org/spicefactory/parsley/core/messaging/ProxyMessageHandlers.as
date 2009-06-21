package org.spicefactory.parsley.core.messaging {
import org.spicefactory.lib.errors.IllegalArgumentError;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class ProxyMessageHandlers {
	
	
	private static var _genericEventCount:int = 0;
	private static var _test1Count:int = 0;
	private static var _test2Count:int = 0;
	
	private static var _instanceCount:int = 0;
	
	
	function ProxyMessageHandlers () {
		_instanceCount++;
	}
	
	
	
	public static function reset () : void {
		_test1Count = 0;
		_test2Count = 0;
		_genericEventCount = 0;
		_instanceCount = 0;
	}

	
	public static function get test1Count () : int {
		return _test1Count;
	}
	
	public static function get test2Count () : int {
		return _test2Count;
	}
	
	public static function get instanceCount ():int {
		return _instanceCount;
	}
	
	public static function get genericEventCount ():int {
		return _genericEventCount;
	}
	

	[MessageHandler(createInstance="true")]
	public function allTestEvents (event:TestEvent) : void {
		if (event.type == TestEvent.TEST1) {
			_test1Count++;
		}
		else if (event.type == TestEvent.TEST2) {
			_test2Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + event.type);
		}
	}
	
	[MessageHandler(createInstance="true")]
	public function allEvents (event:Event) : void {
		_genericEventCount++;
	}
	
	[MessageHandler(selector="test1", createInstance="true")]
	public function event1 (event:TestEvent) : void {
		if (event.type == TestEvent.TEST1) {
			_test1Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + event.type);
		}
	}
	
	[MessageHandler(selector="test2", createInstance="true")]
	public function event2 (event:TestEvent) : void {
		if (event.type == TestEvent.TEST2) {
			_test2Count++;
		}
		else {
			throw new IllegalArgumentError("Unexpected event type: " + event.type);
		}
	}
	
	
}
}
