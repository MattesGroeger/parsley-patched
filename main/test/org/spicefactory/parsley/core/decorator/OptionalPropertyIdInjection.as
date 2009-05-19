package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class OptionalPropertyIdInjection {
	
	
	[Inject(id="missingId", required="false")]
	public var dependency:MissingDependency;
	
	
}
}
