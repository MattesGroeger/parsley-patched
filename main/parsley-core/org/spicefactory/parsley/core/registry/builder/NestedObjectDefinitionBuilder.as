package org.spicefactory.parsley.core.registry.builder {
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;

/**
 * @author Jens Halm
 */
public interface NestedObjectDefinitionBuilder {
	
	
	function addDecorator (decorator:ObjectDefinitionDecorator) : NestedObjectDefinitionBuilder;

	function addAllDecorators (decorators:Array) : NestedObjectDefinitionBuilder;
	
	function build () : ObjectDefinition;
	
	
}
}
