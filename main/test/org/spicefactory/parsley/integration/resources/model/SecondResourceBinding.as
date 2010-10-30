package org.spicefactory.parsley.integration.resources.model {

/**
 * @author Jens Halm
 */
public class SecondResourceBinding {
	
	
	[Bindable]
	[ResourceBinding(bundle="test", key="bind2")]
	public var boundValue:String;
	
	
}
}
