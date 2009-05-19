package org.spicefactory.parsley.core.decorator {
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;

/**
 * @author Jens Halm
 */
public class DecoratorTestContainer {
	
	
	public function get injectedDependency () : InjectedDependency {
		return new InjectedDependency();
	}
	

	public function get requiredConstructorInjection () : ObjectDefinitionFactory {
		return new DefaultObjectDefinitionFactory(RequiredConstructorInjection, "requiredConstructorInjection", true);
	}
	
	public function get missingConstructorInjection () : ObjectDefinitionFactory {
		return new DefaultObjectDefinitionFactory(MissingConstructorInjection, "missingConstructorInjection", true);
	}
	
	public function get optionalConstructorInjection () : ObjectDefinitionFactory {
		return new DefaultObjectDefinitionFactory(OptionalConstructorInjection, "optionalConstructorInjection", true);
	}
	

	[ObjectDefinition(lazy="true")]
	public function get requiredMethodInjection () : RequiredMethodInjection {
		return new RequiredMethodInjection();
	}

	[ObjectDefinition(lazy="true")]
	public function get missingMethodInjection () : MissingMethodInjection {
		return new MissingMethodInjection();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get optionalMethodInjection () : OptionalMethodInjection {
		return new OptionalMethodInjection();
	}
	
		
	
	[ObjectDefinition(lazy="true")]
	public function get requiredPropertyInjection () : RequiredPropertyInjection {
		return new RequiredPropertyInjection();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get missingPropertyInjection () : MissingPropertyInjection {
		return new MissingPropertyInjection();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get optionalPropertyInjection () : OptionalPropertyInjection {
		return new OptionalPropertyInjection();
	}
	
	
	
	[ObjectDefinition(lazy="true")]
	public function get requiredPropertyIdInjection () : RequiredPropertyIdInjection {
		return new RequiredPropertyIdInjection();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get missingPropertyIdInjection () : MissingPropertyIdInjection {
		return new MissingPropertyIdInjection();
	}
	
	[ObjectDefinition(lazy="true")]
	public function get optionalPropertyIdInjection () : OptionalPropertyIdInjection {
		return new OptionalPropertyIdInjection();
	}
	
	
	
}
}
