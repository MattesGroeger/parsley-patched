package org.spicefactory.parsley.integration.pimento {
import org.spicefactory.parsley.integration.pimento.config.CinnamonMxmlConfig;
import org.spicefactory.parsley.integration.pimento.config.PimentoMxmlConfig;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.context.Context;

public class PimentoMxmlTagTest extends PimentoTestBase {

	
	public override function get pimentoContext () : Context {
		return ActionScriptContextBuilder.build(PimentoMxmlConfig);
	}
	
	public override function get cinnamonContext () : Context {
		return ActionScriptContextBuilder.build(CinnamonMxmlConfig);
	}
	
	
}

}