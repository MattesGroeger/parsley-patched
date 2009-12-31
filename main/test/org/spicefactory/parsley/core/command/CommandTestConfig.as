package org.spicefactory.parsley.core.command {
import org.spicefactory.parsley.core.command.model.CommandExecutorsMetadata;
import org.spicefactory.parsley.core.command.model.CommandObserversMetadata;
import org.spicefactory.parsley.core.command.model.CommandStatusFlagsMetadata;
import org.spicefactory.parsley.core.messaging.model.ErrorHandlersMetadata;

/**
 * @author Jens Halm
 */
public class CommandTestConfig {
	
	
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
