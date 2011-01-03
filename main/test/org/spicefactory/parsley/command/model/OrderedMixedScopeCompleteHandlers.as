package org.spicefactory.parsley.command.model {
import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
import org.spicefactory.parsley.util.MessageCounter;

/**
 * @author Jens Halm
 */
public class OrderedMixedScopeCompleteHandlers extends MessageCounter {
	
	public static var order:OrderBuilder;
	
	private var prefix:String;
	
	function OrderedMixedScopeCompleteHandlers (prefix:String) {
		this.prefix = prefix;
	}

	public function handleLocalCommand (message:String) : void {
		order.add(prefix + ":A");
	}
	
	public function handleGlobalCommand (message:Object) : void {
		order.add(prefix + ":B");
	}
	
	public function handleLocalCommand2 (message:Object) : void {
		order.add(prefix + ":C");
	}
	
	public function handleGlobalCommand2 (message:String) : void {
		order.add(prefix + ":D");
	}
	
	public function interceptLocalCommand (message:String, processor:CommandObserverProcessor) : void {
		order.add(prefix + ":I");
	}
	
}
}
