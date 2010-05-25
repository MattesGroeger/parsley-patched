package org.spicefactory.parsley.flex.view {
import org.spicefactory.parsley.config.Configurations;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;

/**
 * @author Jens Halm
 */
public class TestDslProcessor implements ConfigurationProcessor {
	
	
	public var foo:String;
	
	
	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		var builder:ObjectDefinitionBuilder = Configurations.forRegistry(registry).builders.forClass(DslModel);
		builder.property("value").value(foo);
		builder.asSingleton().register();
	}
	
}
}
