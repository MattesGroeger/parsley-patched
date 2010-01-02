package org.spicefactory.parsley.core.command.model {
import org.spicefactory.parsley.core.command.mock.MockResult;
import org.spicefactory.parsley.core.messaging.TestEvent;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class DynamicCommand {
	
	
	
	public static var instances:Array = new Array();
	
	
	
	public var handlerCount:int = 0;
	
	public var commandCount:int = 0;

	public var destroyCount:int = 0;
	
	public var resultValue:String = "none";
	
	public var errorValue:String= "none";
	
	public var prop:int = 0;
	
	
	function DynamicCommand () {
		instances.push(this);
	}
	
	
	public function execute (event:TestEvent) : MockResult {
		commandCount++;
		return new MockResult("foo" + commandCount, (event.stringProp == "error"));
	}
	
	public function result (resultValue:String, message:Event) : void {
		this.resultValue = resultValue;
	}
	
	public function errorHandler (resultValue:String) : void {
		this.errorValue = resultValue;
	}
	
	[MessageHandler]
	public function handleMessage (message:String) : void {
		handlerCount++;
	}
	
	public function destroy () : void {
		destroyCount++;
	}
	
	
}
}
