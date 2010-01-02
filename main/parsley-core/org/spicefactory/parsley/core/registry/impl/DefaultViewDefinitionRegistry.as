/*
 * Copyright 2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ViewDefinition;
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
	public function registerDefinition (viewDefinition:ViewDefinition) : void {
		checkState();
		if (viewDefinition.id != null) {
			if (definitionsById[viewDefinition.id] != null) {
				throw new ContextError("Duplicate id for view definition: " + viewDefinition.id);
			}
			definitionsById[viewDefinition.id] = viewDefinition;
		}
		definitions.push(viewDefinition);
	}

	/**
	 * @inheritDoc
	 */
	public function getDefinitionById (id:String, configTarget:Object) : ViewDefinition {
		var definition:ViewDefinition = definitionsById[id] as ViewDefinition;
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
	public function getDefinitionByType (configTarget:Object) : ViewDefinition {
		var match:ViewDefinition = null;
		for each (var definition:ViewDefinition in definitions) {
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
