package org.spicefactory.parsley.command {
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.command.config.DynamicCommandMxmlConfig;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class DynamicCommandMxmlTagTest extends DynamicCommandTestBase {
	
	
	[BeforeClass]
	public static function prepareFactory () : void {
		CommandTestBase.registerMockCommandFactory();
	}
	
	public override function get commandContext () : Context {
		return ActionScriptContextBuilder.build(DynamicCommandMxmlConfig);
	}
		
	
}
}
