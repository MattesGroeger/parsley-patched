package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class MissingPropertyIdInjection {
	
	
	[Inject(id="missingId")]
	public var dependency:MissingDependency;
	
	
}
}
