package org.spicefactory.parsley.core.command.model {
import org.spicefactory.parsley.core.messaging.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandObserversMetadata extends CommandObservers {
	
	
	[CommandResult(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]	
	public override function noParam () : void {
		super.noParam();
	}
	
	[CommandComplete(selector="test1")]
	public override function oneParamComplete (message:TestEvent) : void {
		super.oneParamComplete(message);
	}
	
	[CommandResult(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]	
	public override function oneParam (result:String) : void {
		super.oneParam(result);
	}
	
	[CommandResult(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]	
	public override function twoParams (result:String, message:TestEvent) : void {
		super.twoParams(result, message);
	}
	
	[CommandError(type="org.spicefactory.parsley.core.messaging.TestEvent", selector="test1")]	
	public override function error (result:String, message:TestEvent) : void {
		super.error(result, message);
	}

	
}
}
