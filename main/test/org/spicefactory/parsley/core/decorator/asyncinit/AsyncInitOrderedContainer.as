package org.spicefactory.parsley.core.decorator.asyncinit {

/**
 * @author Jens Halm
 */
public class AsyncInitOrderedContainer {

	
	public function get asyncInitModel2 () : AsyncInitOrderedModel2 {
		return new AsyncInitOrderedModel2();
	}
	
	public function get asyncInitModel1 () : AsyncInitOrderedModel1 {
		return new AsyncInitOrderedModel1();
	}
	
	
}
}
