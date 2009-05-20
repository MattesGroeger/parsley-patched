package org.spicefactory.parsley.core.decorator.factory {
	import org.spicefactory.parsley.core.decorator.injection.RequiredMethodInjection;
	import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.lib.errors.IllegalStateError;

/**
 * @author Jens Halm
 */
public class TestFactory {
	
	
	[Inject]
	public var dependency:InjectedDependency;
	
	
	[Factory]
	public function createInstance () : RequiredMethodInjection {
		if (dependency == null) {
			throw new IllegalStateError("Dependency not injected");
		}
		return new RequiredMethodInjection();
	}
	
	
}
}
