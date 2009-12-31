package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.parsley.core.messaging.command.CommandStatus;

[Metadata(name="CommandResult", types="method", multiple="true")]

/**
 * Represents a Metadata, MXML or XML tag that can be used on methods which wish to be invoked when
 * the result of a matching asynchronous command execution has been received.
 * 
 * @author Jens Halm
 */
public class CommandResultDecorator extends AbstractCommandObserverDecorator {
	
	/**
	 * @private
	 */
	function CommandResultDecorator () {
		super(CommandStatus.COMPLETE);
	}
	
}
}
