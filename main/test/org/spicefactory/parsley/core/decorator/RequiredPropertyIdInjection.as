package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class RequiredPropertyIdInjection {
	
	
	[Inject(id="injectedDependency")]
	public var dependency:InjectedDependency;
	
	
}
}
