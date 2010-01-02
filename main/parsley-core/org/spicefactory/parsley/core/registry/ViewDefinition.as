package org.spicefactory.parsley.core.registry {
import org.spicefactory.parsley.core.registry.ObjectDefinition;

/**
 * Represents the configuration for a dynamically wired view.
 * These are usually components or presentation models declared in an MXML component
 * that dispatches a configureView event to be wired to the Context.
 * 
 * @author Jens Halm
 */
public interface ViewDefinition extends ObjectDefinition {
	
	/**
	 * The optional id to use when matching this configuration with
	 * a dynamically wired view instance. Usually the name of the component
	 * will be used to match against this id.
	 */
	function get id () : String;
	
}
}
