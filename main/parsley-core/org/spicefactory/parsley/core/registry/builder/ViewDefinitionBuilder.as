package org.spicefactory.parsley.core.registry.builder {
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;

/**
 * @author Jens Halm
 */
public interface ViewDefinitionBuilder {
	
	
	function setId (id:String) : ViewDefinitionBuilder;

	function addDecorator (decorator:ObjectDefinitionDecorator) : ViewDefinitionBuilder;

	function addAllDecorators (decorators:Array) : ViewDefinitionBuilder;
	
	function build () : ObjectDefinition;
	
	
}
}
