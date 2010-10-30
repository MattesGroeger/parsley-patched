package org.spicefactory.parsley.command.sync {
import org.spicefactory.parsley.messaging.messages.TestEvent;

/**
 * @author Jens Halm
 */
public class CommandExecutor {
	
	
	
	[Command]
	public function synchronousCommand (event:TestEvent) : void {
		/* nothing to do */
	}
	
	
}
}
