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
