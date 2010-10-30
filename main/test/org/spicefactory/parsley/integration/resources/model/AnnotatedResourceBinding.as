package org.spicefactory.parsley.integration.resources.model {

/**
 * @author Jens Halm
 */
public class AnnotatedResourceBinding {
	
	
	[Bindable]
	[ResourceBinding(bundle="test", key="bind")]
	public var boundValue:String;
	
	
}
}
