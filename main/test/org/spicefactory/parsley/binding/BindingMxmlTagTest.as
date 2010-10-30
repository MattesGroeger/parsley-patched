package org.spicefactory.parsley.binding {

import org.spicefactory.parsley.binding.config.BindingMxmlConfig;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.FlexConfig;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * @author Jens Halm
 */
public class BindingMxmlTagTest extends BindingTestBase {
	
	
	protected override function get bindingContext () : Context {
		return FlexContextBuilder.build(BindingMxmlConfig);
	}
	
	protected override function addConfig (builder:CompositeContextBuilder) : void {
		builder.addProcessor(FlexConfig.forClass(BindingMxmlConfig));
	}
	
}
}
