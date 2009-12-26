package org.spicefactory.parsley.core.registry {



/**
 * Interface that can be used by the various configuration mechanisms to create tags
 * that produce view definitions.
 * 
 * @author Jens Halm
 */
public interface ViewDefinitionFactory {
	
	/**
	 * The optional id the view definition produced by this factory should be registered with.
	 */
	function get configId () : String;
	
	/**
	 * Creates a view definition that can be applied to dynamically wired views.
	 * 
	 * @param registry the registry that the new definition will belong to
	 * @return a new view definition
	 */
	function createDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition;

}
}
