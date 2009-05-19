package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class DecoratorTestContainer {
	
	
	public function get injectedDependency () : InjectedDependency {
		return new InjectedDependency();
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
