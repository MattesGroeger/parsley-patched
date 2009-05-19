package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class OptionalPropertyInjection {
	
	
	[Inject(required="false")]
	public var dependency:MissingDependency;
	
	
}
}
