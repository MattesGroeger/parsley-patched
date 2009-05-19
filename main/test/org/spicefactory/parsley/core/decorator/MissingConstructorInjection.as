package org.spicefactory.parsley.core.decorator {

[InjectConstructor]
/**
 * @author Jens Halm
 */
public class MissingConstructorInjection {
	
	
	private var _dependency:MissingDependency;
	
	
	function MissingConstructorInjection (dep:MissingDependency) {
		_dependency = dep;
	}


	public function get dependency () : MissingDependency {
		return _dependency;
	}
	
	
}
}
