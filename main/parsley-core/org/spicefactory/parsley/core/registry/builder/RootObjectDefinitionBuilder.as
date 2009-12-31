package org.spicefactory.parsley.core.registry.builder {
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;

/**
 * @author Jens Halm
 */
public interface RootObjectDefinitionBuilder {
	
	
	function setId (id:String) : RootObjectDefinitionBuilder;

	function setLazy (lazy:Boolean) : RootObjectDefinitionBuilder;

	function setSingleton (singleton:Boolean) : RootObjectDefinitionBuilder;

	function setOrder (order:int) : RootObjectDefinitionBuilder;

	function setInstantiator (instantiator:ObjectInstantiator) : RootObjectDefinitionBuilder;
	
	function addDecorator (decorator:ObjectDefinitionDecorator) : RootObjectDefinitionBuilder;

	function addAllDecorators (decorators:Array) : RootObjectDefinitionBuilder;
	
	function build () : RootObjectDefinition;
	
	
}
}
