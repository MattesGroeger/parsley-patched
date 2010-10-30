package org.spicefactory.parsley.command {
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.command.config.CommandMxmlConfig;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class CommandMxmlTagTest extends CommandTestBase {
	
	
	
	[BeforeClass]
	public static function prepareFactory () : void {
		registerMockCommandFactory();
	}
	
	public override function get commandContext () : Context {
		return ActionScriptContextBuilder.build(CommandMxmlConfig);
	}
		
	
}
}
