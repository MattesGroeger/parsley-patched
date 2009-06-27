package org.spicefactory.parsley.flex.mxmlconfig.messaging {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.messaging.MessagingTestBase;

/**
 * @author Jens Halm
 */
public class MessagingMxmlTagTest extends MessagingTestBase {
	
	
	public override function get messagingContext () : Context {
		return ActionScriptContextBuilder.build(MessagingMxmlTagContainer);
	}
		
	
}
}
