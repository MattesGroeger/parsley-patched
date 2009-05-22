package org.spicefactory.parsley.testmodel {

/**
 * @author Jens Halm
 */
public class AnnotatedResourceBinding {
	
	
	[ResourceBinding(bundleName="test", resourceName="bind")]
	public var boundValue:String;
	
	
}
}
