package org.spicefactory.parsley.core.decorator.lifecycle {

	import org.spicefactory.parsley.core.decorator.lifecycle.PostConstructModel;
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
