package org.spicefactory.parsley.core.decorator.factory {
import org.spicefactory.parsley.core.decorator.factory.model.TestFactoryMetadata;
import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;

/**
 * @author Jens Halm
 */
public class FactoryDecoratorTestContainer {
	

	public function get injectedDependency () : InjectedDependency {
		return new InjectedDependency();
	}
	
	[ObjectDefinition(lazy="true")] 
	public function get factoryWithDependency () : TestFactoryMetadata {
		return new TestFactoryMetadata();
	}

	
}
}
