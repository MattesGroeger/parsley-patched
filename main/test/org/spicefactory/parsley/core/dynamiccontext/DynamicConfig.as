package org.spicefactory.parsley.core.dynamiccontext {

/**
 * @author Jens Halm
 */
public class DynamicConfig {
	
	
	public function get dependency () : DynamicTestDependency {
		return new DynamicTestDependency();
	}
	
	
}
}
