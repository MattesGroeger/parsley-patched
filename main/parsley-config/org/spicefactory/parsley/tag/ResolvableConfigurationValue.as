package org.spicefactory.parsley.tag {
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

/**
 * Represents a configuration value that needs to be resolved before being passed to 
 * an ObjectDefinition. Can be used for any tag that specifies a nested value
 * in an ObjectDefinition, like those tags nested within <code>ConstructorArgs</code>
 * or <code>Array</code> tags. For any nested tags that do not implement this 
 * interface the tag instance itself will be used as the value.
 * 
 * @author Jens Halm
 */
public interface ResolvableConfigurationValue {
	
	
	/**
	 * Returns the resolved value represented by this tag.
	 * 
	 * @param registry the registry that this tag belongs to
	 * @return the resolved value represented by this tag
	 */
	function resolve (registry:ObjectDefinitionRegistry) : *;
	
	
}
}
