package org.spicefactory.parsley.command.sync {

/**
 * @author Jens Halm
 */
public class CommandObserver {
	
	
	public var result:*;
	
	public var counter:uint = 0;
	
	
	[CommandResult(selector="test1")]
	public function observeWithResultParam (result:*) : void {
		this.result = result;
		this.counter++;
	}
	
	
}
}
