package org.spicefactory.parsley.command.model {
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author jenshalm
 */
public class OverrideCommandResultModel {
	
	public var invocationOrder:String = "";
	
	[CommandComplete(order="1")]
	public function firstComplete (message:TestEvent) : void {
		invocationOrder += "A";
	}

	[CommandComplete(order="2")]
	public function secondComplete (message:TestEvent, processor:CommandObserverProcessor) : void {
		invocationOrder += "B";
		processor.command.setResult("newResult", CommandStatus.ERROR);
	}
	
	[CommandComplete(order="3")]
	public function thirdComplete (message:TestEvent) : void {
		invocationOrder += "Z";
	}
	
	[CommandError(order="1")]	
	public function error (result:Object, message:TestEvent) : void {
		invocationOrder += "C";
	}
	
}
}
