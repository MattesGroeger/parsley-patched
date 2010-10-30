package org.spicefactory.parsley.lifecycle.observer.config {
import org.spicefactory.parsley.lifecycle.methods.model.LifecycleEventCounterMetadata;

/**
 * @author Jens Halm
 */
public class ObserveCounterAsConfig {
	
	
	public function get counter () : LifecycleEventCounterMetadata {
		return new LifecycleEventCounterMetadata();
	}

	
}
}
