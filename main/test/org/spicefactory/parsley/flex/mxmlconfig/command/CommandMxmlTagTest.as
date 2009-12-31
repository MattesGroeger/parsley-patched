package org.spicefactory.parsley.flex.mxmlconfig.command {
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.command.CommandTestBase;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class CommandMxmlTagTest extends CommandTestBase {
	
	
	public override function get commandContext () : Context {
		return ActionScriptContextBuilder.build(CommandMxmlTagConfig);
	}
		
	
}
}
