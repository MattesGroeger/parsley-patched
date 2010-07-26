package org.spicefactory.parsley.core.command.model {
import org.spicefactory.parsley.core.messaging.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandObservers {
	
	
	public var noParamCalled:uint;

	public var completeInvoked:uint;

	public var oneParamResult:Array = new Array();

	public var twoParamsResult:Array = new Array();

	public var twoParamsMessage:Array = new Array();
	
	public var errorResult:Array = new Array();

	public var errorMessage:Array = new Array();
	
	
	public function noParam () : void {
		noParamCalled++;
	}
	
	public function oneParam (result:String) : void {
		oneParamResult.push(result);
	}
	
	public function oneParamComplete (message:TestEvent) : void {
		completeInvoked++;
	}
	
	public function twoParams (result:String, message:TestEvent) : void {
		twoParamsResult.push(result);
		twoParamsMessage.push(message);
	}
	
	public function error (result:String, message:TestEvent) : void {
		errorResult.push(result);
		errorMessage.push(message);
	}

	public function reset () : void {
		noParamCalled = 0;
		oneParamResult = new Array();
		twoParamsResult = new Array();
		twoParamsMessage = new Array();
		errorResult = new Array();
		errorMessage = new Array();
	}
	
	
}
}
