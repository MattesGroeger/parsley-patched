package org.spicefactory.parsley.flex.mxmlconfig.binding {
import org.spicefactory.parsley.binding.BindingTestBase;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.FlexConfig;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * @author Jens Halm
 */
public class BindingMxmlTagTest extends BindingTestBase {
	
	
	protected override function get bindingContext () : Context {
		return FlexContextBuilder.build(BindingConfig);
	}
	
	protected override function addConfig (builder:CompositeContextBuilder) : void {
		builder.addProcessor(FlexConfig.forClass(BindingConfig));
	}
	
}
}
