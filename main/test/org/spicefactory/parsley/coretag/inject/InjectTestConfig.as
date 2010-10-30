package org.spicefactory.parsley.coretag.inject {

	import org.spicefactory.parsley.coretag.inject.model.ArrayPropertyInjection;
	import org.spicefactory.parsley.coretag.inject.model.MissingPropertyInjection;
	import org.spicefactory.parsley.coretag.inject.model.OptionalPropertyInjection;
	import org.spicefactory.parsley.coretag.inject.model.MissingMethodInjection;
	import org.spicefactory.parsley.coretag.inject.model.OptionalConstructorInjection;
	import org.spicefactory.parsley.coretag.inject.model.RequiredMethodInjection;
	import org.spicefactory.parsley.coretag.inject.model.OptionalMethodInjection;
	import org.spicefactory.parsley.coretag.inject.model.RequiredPropertyInjection;
	import org.spicefactory.parsley.coretag.inject.model.InjectedDependency;
	import org.spicefactory.parsley.coretag.inject.model.RequiredConstructorInjection;
	import org.spicefactory.parsley.coretag.inject.model.OptionalPropertyIdInjection;
	import org.spicefactory.parsley.coretag.inject.model.MissingConstructorInjection;
	import org.spicefactory.parsley.coretag.inject.model.MissingPropertyIdInjection;
	import org.spicefactory.parsley.coretag.inject.model.RequiredPropertyIdInjection;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;

/**
 * @author Jens Halm
 */
public class InjectTestConfig {
	
	
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
	public function get arrayPropertyInjection () : ArrayPropertyInjection {
		return new ArrayPropertyInjection();
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
	
	
	public function get date1 () : Date {
		return new Date();
	}
	
	public function get date2 () : Date {
		return new Date();
	}
	
	public function get date3 () : Date {
		return new Date();
	}
	
	
	
}
}
