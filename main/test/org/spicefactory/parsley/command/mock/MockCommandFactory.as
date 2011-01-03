package org.spicefactory.parsley.command.mock {
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;

/**
 * @author Jens Halm
 */
public class MockCommandFactory implements CommandFactory {


	private var commands:Array = new Array();
	
	
	public function getNextCommand () : MockCommand {
		return commands.shift() as MockCommand;
	}
	
	public function get commandCount () : uint {
		return commands.length; 
	}

	public function dispatchAll () : void {
		for each (var com:MockCommand in commands) {
			com.dispatchResult();
		}
	}
	
	public function reset () : void {
		commands = new Array();
	}
	
	
	public function createCommand (returnValue:Object, message:Message) : Command {
		var command:MockCommand = new MockCommand(message, MockResult(returnValue));
		commands.push(command);
		return command;
	}
}
}

import org.spicefactory.parsley.command.mock.MockResult;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.command.impl.AbstractCommand;

class MockCommand extends AbstractCommand {


	private var result:MockResult;


	function MockCommand (message:Message, result:MockResult) {
		super(result, message);
		this.result = result;
		start();
	}
	
	
	public function dispatchResult () : void {
		if (result.error) {
			error(result.value); 
		}
		else {
			complete(result.value); 
		}
	}
	
	
}
