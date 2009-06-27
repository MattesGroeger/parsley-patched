package org.spicefactory.parsley.core.messaging {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;

/**
 * @author Jens Halm
 */
public class MessagingMetadataTagTest extends MessagingTestBase {
	
	
	public override function get messagingContext () : Context {
		return ActionScriptContextBuilder.build(MessagingTestContainer);
	}
	
	
}
}
