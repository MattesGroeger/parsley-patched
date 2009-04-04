package org.spicefactory.parsley.flex.view {
import flash.utils.Dictionary;

import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.impl.ChildContext;
import org.spicefactory.parsley.core.impl.ObjectFactory;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

import mx.core.UIComponent;

/**
 * @author Jens Halm
 */
public class FlexViewContext extends ChildContext {
	
	
	private var definitionMap:Dictionary = new Dictionary();

	
	public function FlexViewContext (parent:Context, registry:ObjectDefinitionRegistry = null, 
			factory:ObjectFactory = null) {
		super(parent, registry, factory);
	}
	
	
	public function addComponent (component:UIComponent, definition:ObjectDefinition) : void {
		factory.configureObject(component, definition, this);
		definitionMap[component] = definition;
	}
	
	
	public function removeComponent (component:UIComponent) : void {
		var definition:ObjectDefinition = ObjectDefinition(definitionMap[component]);
		if (definition != null) {
			factory.destroyObject(component, definition, this);
		}
	}
	
	
}
}
