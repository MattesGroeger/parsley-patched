package org.spicefactory.parsley.core.decorator {

[InjectConstructor]
/**
 * @author Jens Halm
 */
public class RequiredConstructorInjection {
	
	
	private var _dependency:InjectedDependency;
	
	
	function RequiredConstructorInjection (dep:InjectedDependency) {
		_dependency = dep;
	}


	public function get dependency () : InjectedDependency {
		return _dependency;
	}
	
	
}
}
