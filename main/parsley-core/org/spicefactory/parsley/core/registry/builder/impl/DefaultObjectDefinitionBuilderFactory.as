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

package org.spicefactory.parsley.core.registry.builder.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.builder.NestedObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.builder.ObjectDefinitionBuilderFactory;
import org.spicefactory.parsley.core.registry.builder.RootObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.builder.ViewDefinitionBuilder;

/**
 * Default implementation of the ObjectDefinitionBuilderFactory interface.
 * 
 * @author Jens Halm
 */
public class DefaultObjectDefinitionBuilderFactory implements ObjectDefinitionBuilderFactory {

	private var registry:ObjectDefinitionRegistry;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param registry the registry associated with this builder
	 */
	function DefaultObjectDefinitionBuilderFactory (registry:ObjectDefinitionRegistry) {
		this.registry = registry;
	}
	
	/**
	 * @inheritDoc
	 */
	public function forRootDefinition (type:Class) : RootObjectDefinitionBuilder {
		return new DefaultRootObjectDefinitionBuilder(ClassInfo.forClass(type, registry.domain), registry);
	}
	
	/**
	 * @inheritDoc
	 */
	public function forNestedDefinition (type:Class) : NestedObjectDefinitionBuilder {
		return new DefaultNestedObjectDefinitionBuilder(ClassInfo.forClass(type, registry.domain), registry);
	}
	
	/**
	 * @inheritDoc
	 */
	public function forViewDefinition (type:Class) : ViewDefinitionBuilder {
		return new DefaultViewDefinitionBuilder(ClassInfo.forClass(type, registry.domain), registry);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.builder.NestedObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.builder.RootObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.builder.ViewDefinitionBuilder;
import org.spicefactory.parsley.core.registry.builder.impl.AbstractObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.definition.ObjectInstantiator;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinition;
import org.spicefactory.parsley.core.registry.impl.DefaultRootObjectDefinition;
import org.spicefactory.parsley.core.registry.impl.IdGenerator;

class DefaultRootObjectDefinitionBuilder extends AbstractObjectDefinitionBuilder implements RootObjectDefinitionBuilder {


	private var id:String;
	private var lazy:Boolean = false;
	private var singleton:Boolean = true;
	private var order:int = int.MAX_VALUE;
	private var instantiator:ObjectInstantiator;

	
	function DefaultRootObjectDefinitionBuilder (type:ClassInfo, registry:ObjectDefinitionRegistry) {
		super(type, registry);
	}
	
	
	public function setId (id:String) : RootObjectDefinitionBuilder {
		this.id = id;
		return this;
	}
	
	public function setLazy (lazy:Boolean) : RootObjectDefinitionBuilder {
		this.lazy = lazy;
		return this;
	}
	
	public function setSingleton (singleton:Boolean) : RootObjectDefinitionBuilder {
		this.singleton = singleton;
		return this;
	}
	
	public function setOrder (order:int) : RootObjectDefinitionBuilder {
		this.order = order;		
		return this;
	}
	
	public function setInstantiator (instantiator:ObjectInstantiator) : RootObjectDefinitionBuilder {
		this.instantiator = instantiator;
		return this;
	}

	public function addDecorator (decorator:ObjectDefinitionDecorator) : RootObjectDefinitionBuilder {
		decorators.push(decorator);		
		return this;
	}
	
	public function addAllDecorators (decorators:Array) : RootObjectDefinitionBuilder {
		this.decorators = this.decorators.concat(decorators);		
		return this;
	}
	
	public function build () : RootObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var def:RootObjectDefinition = new DefaultRootObjectDefinition(type, id, registry, lazy, singleton, order);
		def.instantiator = instantiator;
		def = processDecorators(registry, def) as RootObjectDefinition;
		return def;
	}
	
	
}


class DefaultViewDefinitionBuilder extends AbstractObjectDefinitionBuilder implements ViewDefinitionBuilder {


	private var id:String;

	
	function DefaultViewDefinitionBuilder (type:ClassInfo, registry:ObjectDefinitionRegistry) {
		super(type, registry);
	}
	
	
	public function setId (id:String) : ViewDefinitionBuilder {
		this.id = id;
		return this;
	}

	public function addDecorator (decorator:ObjectDefinitionDecorator) : ViewDefinitionBuilder {
		decorators.push(decorator);		
		return this;
	}
	
	public function addAllDecorators (decorators:Array) : ViewDefinitionBuilder {
		this.decorators = this.decorators.concat(decorators);		
		return this;
	}
	
	public function build () : ObjectDefinition {
		if (id == null) id = IdGenerator.nextObjectId;
		var def:ObjectDefinition = new DefaultObjectDefinition(type);
		def = processDecorators(registry, def) as ObjectDefinition;
		return def;
	}
	
}


class DefaultNestedObjectDefinitionBuilder extends AbstractObjectDefinitionBuilder implements NestedObjectDefinitionBuilder {


	function DefaultNestedObjectDefinitionBuilder (type:ClassInfo, registry:ObjectDefinitionRegistry) {
		super(type, registry);
	}
	
	
	public function addDecorator (decorator:ObjectDefinitionDecorator) : NestedObjectDefinitionBuilder {
		decorators.push(decorator);		
		return this;
	}
	
	public function addAllDecorators (decorators:Array) : NestedObjectDefinitionBuilder {
		this.decorators = this.decorators.concat(decorators);		
		return this;
	}
	
	public function build () : ObjectDefinition {
		var def:ObjectDefinition = new DefaultObjectDefinition(type);
		def = processDecorators(registry, def) as ObjectDefinition;
		return def;
	}
	
}