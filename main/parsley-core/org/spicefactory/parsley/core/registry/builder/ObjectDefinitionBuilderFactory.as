package org.spicefactory.parsley.core.registry.builder {

/**
 * @author Jens Halm
 */
public interface ObjectDefinitionBuilderFactory {
	
	function forRootDefinition (type:Class) : RootObjectDefinitionBuilder;

	function forNestedDefinition (type:Class) : NestedObjectDefinitionBuilder;

	function forViewDefinition (type:Class) : ViewDefinitionBuilder;
	
}
}
