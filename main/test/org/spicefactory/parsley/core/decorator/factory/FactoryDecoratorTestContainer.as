package org.spicefactory.parsley.core.decorator.factory {
	import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
	import org.spicefactory.parsley.core.decorator.factory.TestFactory;
import org.spicefactory.parsley.registry.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.registry.ObjectDefinitionFactory;

/**
 * @author Jens Halm
 */
public class FactoryDecoratorTestContainer {
	

	public function get injectedDependency () : InjectedDependency {
		return new InjectedDependency();
	}
	
	public function get factoryWithDependency () : ObjectDefinitionFactory {
		return new DefaultObjectDefinitionFactory(TestFactory, "factoryWithDependency", true);
	}

	
}
}
