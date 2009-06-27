package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.parsley.core.decorator.asyncinit.model.AsyncInitModelMetadataOrder1;
import org.spicefactory.parsley.core.decorator.asyncinit.model.AsyncInitModelMetadataOrder2;

/**
 * @author Jens Halm
 */
public class AsyncInitOrderedContainer {

	
	public function get asyncInitModel1 () : AsyncInitModelMetadataOrder1 {
		return new AsyncInitModelMetadataOrder1();
	}
	
	public function get asyncInitModel2 () : AsyncInitModelMetadataOrder2 {
		return new AsyncInitModelMetadataOrder2();
	}
	
	
}
}
