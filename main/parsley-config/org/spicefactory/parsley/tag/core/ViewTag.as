package org.spicefactory.parsley.tag.core {
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ViewDefinitionFactory;

[DefaultProperty("decorators")]

/**
 * Represents the root view tag for an object definition in MXML or XML configuration.
 * 
 * @author Jens Halm
 */
public class ViewTag implements ViewDefinitionFactory {
	
	
	/**
	 * The optional id the view definition produced by this factory should be registered with.
	 */
	public var id:String;
	
	/**
	 * The type of dynamically wired views the definition produced by this factory should be applied to.
	 */
	public var type:Class = Object;
	
	/**
	 * The ObjectDefinitionDecorator instances added to this definition.
	 */
	public var decorators:Array = new Array();
	

	/**
	 * @inheritDoc
	 */
	public function createDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition {
		var factory:DefaultObjectDefinitionFactory = new DefaultObjectDefinitionFactory(type);
		factory.decorators = decorators;
		return factory.createNestedDefinition(registry);
	}
	
	/**
	 * @private
	 */
	public function get configId () : String {
		return id;
	}
	
	
}
}
