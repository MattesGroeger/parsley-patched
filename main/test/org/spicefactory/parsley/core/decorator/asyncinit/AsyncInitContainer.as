package org.spicefactory.parsley.core.decorator.asyncinit {

/**
 * @author Jens Halm
 */
public class AsyncInitContainer {
	
	
	public function get asyncInitModel () : AsyncInitModel {
		return new AsyncInitModel();
	}
	
	
}
}
