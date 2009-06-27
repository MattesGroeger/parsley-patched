package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;

/**
 * @author Jens Halm
 */
public class AsyncInitMetadataTagTest extends AsyncInitTestBase {
	
	
	protected override function get defaultContext () : Context {
		return ActionScriptContextBuilder.build(AsyncInitContainer);
	}
	
	protected override function get orderedContext () : Context {
		return ActionScriptContextBuilder.build(AsyncInitOrderedContainer);
	}
	
	
}
}
