package org.spicefactory.parsley.core.decorator {

/**
 * @author Jens Halm
 */
public class LifecycleDecoratorTestContainer {
	
	

	[ObjectDefinition(lazy="true")]
	public function get preDestroyModel () : PreDestroyModel {
		return new PreDestroyModel();
	}

	[ObjectDefinition(lazy="true")]
	public function get postConstructModel () : PostConstructModel {
		return new PostConstructModel();
	}
	
	
}
}
