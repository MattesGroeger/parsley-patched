package org.spicefactory.parsley.core.registry {


/**
 * A registry for view definitions. These can then be applied to views
 * that are dynamically wired to the Context. View definitions can be
 * created by MXML or XML configuration or any custom mechanism.
 * 
 * @author Jens Halm
 */
public interface ViewDefinitionRegistry {
	
	/**
	 * Registers a view definition with this registry.
	 * If the id parameter is omitted the view definition can still be matched to
	 * dynamically wired views by type.
	 * 
	 * @param viewDefinition the view definition to add
	 * @param id the id to use to match the definition to dynamically wired views
	 */
	function registerDefinition (viewDefinition:ObjectDefinition, id:String = null) : void;

	/**
	 * Returns the definition matching the specified id and type of the configuration target.
	 * If no definition for the specified id exists or if the type does not match
	 * this method should return null and never throw an Error.
	 * 
	 * @param id the id of the view definition
	 * @param configTarget the target the definition should be applied to
	 * @return the matching view definition or null
	 */
	function getDefinitionById (id:String, configTarget:Object) : ObjectDefinition;

	/**
	 * Returns the definition matching the type of the specified target instance.
	 * If no match is found this method should return null and not throw an Error.
	 * If more than one match is found this method should throw an Error (or may
	 * choose to attempt to look for a "closest match").
	 * 
	 * @param configTarget the target the definition should be applied to
	 * @return the matching view definition or null
	 */
	function getDefinitionByType (configTarget:Object) : ObjectDefinition;
	
	/**
	 * Freezes this registry. After calling this method any attempt to modify this registry or any
	 * of the definitions it contains will lead to an Error.
	 */
	function freeze () : void;
	
	/**
	 * Indicates whether this registry has been frozen. When true any attempt to modify this registry or any
	 * of the definitions it contains will lead to an Error.
	 */	
	function get frozen () : Boolean;
	

}
}
