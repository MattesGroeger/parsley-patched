package org.spicefactory.parsley.command.config {
import org.spicefactory.parsley.command.model.CommandExecutorsMetadata;
import org.spicefactory.parsley.command.model.CommandObserversMetadata;
import org.spicefactory.parsley.command.model.CommandStatusFlagsMetadata;
import org.spicefactory.parsley.messaging.model.ErrorHandlersMetadata;

/**
 * @author Jens Halm
 */
public class CommandAsConfig {
	
	
	[ObjectDefinition(lazy="true")]
	public function get commandStatusFlags () : CommandStatusFlagsMetadata {
		return new CommandStatusFlagsMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get commandExecutors () : CommandExecutorsMetadata {
		return new CommandExecutorsMetadata();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get commandObservers () : CommandObserversMetadata {
		return new CommandObserversMetadata();
	}
	
	public function get errorHandlers () : ErrorHandlersMetadata {
		return new ErrorHandlersMetadata();
	}
	
	
}
}
