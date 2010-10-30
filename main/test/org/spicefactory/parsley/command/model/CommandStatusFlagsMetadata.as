package org.spicefactory.parsley.command.model {

/**
 * @author Jens Halm
 */
public class CommandStatusFlagsMetadata extends CommandStatusFlags {
	

	[CommandStatus(type="org.spicefactory.parsley.messaging.messages.TestEvent")]
	public override function get flag1and2 ():Boolean {
		return super.flag1and2;
	}
	
	public override function set flag1and2 (flag1and2:Boolean):void {
		super.flag1and2 = flag1and2;
	}
	
	[CommandStatus(type="org.spicefactory.parsley.messaging.messages.TestEvent", selector="test1")]
	public override function get flag1 ():Boolean {
		return super.flag1;
	}
	
	public override function set flag1 (flag1:Boolean):void {
		super.flag1 = flag1;
	}
	
	[CommandStatus(type="org.spicefactory.parsley.messaging.messages.TestEvent", selector="test2")]
	public override function get flag2 ():Boolean {
		return super.flag2;
	}
	
	public override function set flag2 (flag2:Boolean):void {
		super.flag2 = flag2;
	}
	
	
}
}
