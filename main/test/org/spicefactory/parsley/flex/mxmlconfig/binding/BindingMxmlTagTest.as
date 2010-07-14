package org.spicefactory.parsley.flex.mxmlconfig.binding {
import org.spicefactory.parsley.binding.BindingTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * @author Jens Halm
 */
public class BindingMxmlTagTest extends BindingTestBase {
	
	
	protected override function get bindingContext () : Context {
		return FlexContextBuilder.build(BindingConfig);
	}
	
	
}
}
