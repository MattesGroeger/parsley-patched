package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ViewDefinitionRegistry;

import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

/**
 * Default implementation of the ViewDefinitionRegistry interface.
 * 
 * @author Jens Halm
 */
public class DefaultViewDefinitionRegistry implements ViewDefinitionRegistry {
	
	
	private var parent:ViewDefinitionRegistry;
	
	private var definitionsById:Dictionary = new Dictionary();
	private var definitions:Array = new Array();
	
	private var _frozen:Boolean;
	
	
	function DefaultViewDefinitionRegistry (parent:ViewDefinitionRegistry) {
		this.parent = parent;
	}

	
	/**
	 * @inheritDoc
	 */
	public function registerDefinition (viewDefinition:ObjectDefinition, id:String = null) : void {
		checkState();
		if (id != null) {
			if (definitionsById[id] != null) {
				throw new ContextError("Duplicate id for view definition: " + id);
			}
			definitionsById[id] = viewDefinition;
		}
		definitions.push(viewDefinition);
	}

	/**
	 * @inheritDoc
	 */
	public function getDefinitionById (id:String, configTarget:Object) : ObjectDefinition {
		var definition:ObjectDefinition = definitionsById[id] as ObjectDefinition;
		if (definition != null && configTarget is definition.type.getClass()) {
			return definition;
		}
		else if (parent != null) {
			return parent.getDefinitionById(id, configTarget);
		}
		else {
			return null;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function getDefinitionByType (configTarget:Object) : ObjectDefinition {
		var match:ObjectDefinition = null;
		for each (var definition:ObjectDefinition in definitions) {
			if (configTarget is definition.type.getClass()) {
				if (match != null) {
					throw new ContextError("More than one view definition for type " 
							+ getQualifiedClassName(configTarget) + " was registered");
				}
				else {
					match = definition;
				}
			}
		}
		if (match == null && parent != null) {
			return parent.getDefinitionByType(configTarget);
		}
		else {
			return match;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function freeze () : void {
		_frozen = true;
		for each (var definition:ObjectDefinition in definitions) {
			definition.freeze();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get frozen () : Boolean {
		return _frozen;
	}
	
	private function checkState () : void {
		if (_frozen) {
			throw new IllegalStateError("Registry is frozen");
		}
	}
	
	
}
}
