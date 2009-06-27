package org.spicefactory.parsley.pimento {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;

public class PimentoMxmlTagTest extends PimentoTestBase {

	
	public override function get pimentoContext () : Context {
		return ActionScriptContextBuilder.build(PimentoMxmlTagContainer);
	}
	
	public override function get cinnamonContext () : Context {
		return ActionScriptContextBuilder.build(CinnamonMxmlTagContainer);
	}
	
	
}

}