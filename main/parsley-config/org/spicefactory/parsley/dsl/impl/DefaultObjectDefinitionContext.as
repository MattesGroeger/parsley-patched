/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.dsl.impl {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.config.Configuration;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.SingletonObjectDefinition;
import org.spicefactory.parsley.dsl.core.ObjectDefinitionReplacer;

import flash.errors.IllegalOperationError;

/**
 * Default implementation of the ObjectDefinitionContext interface.
 * This is primarily used internally and not considered part of the public API.
 * 
 * @author Jens Halm
 */
public class DefaultObjectDefinitionContext implements ObjectDefinitionContext {


	private var _targetType:ClassInfo;
	private var _config:Configuration;
	private var _assemblers:Array;
	
	private var builderParts:Array = new Array();
	private var replacer:ObjectDefinitionReplacer;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param targetType the type of the target object
	 * @param config the configuration for the associated registry
	 * @param assemblers the assemblers to use to assemble the decorators for the target definition
	 */
	function DefaultObjectDefinitionContext (targetType:ClassInfo, config:Configuration, assemblers:Array) {
		_targetType = targetType;
		_config = config;
		_assemblers = assemblers;
	}


	/**
	 * @inheritDoc
	 */
	public function get targetType () : ClassInfo {
		return _targetType;
	}

	/**
	 * @inheritDoc
	 */
	public function get config () : Configuration {
		return _config;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get assemblers () : Array {
		return _assemblers;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addBuilderPart (part:ObjectDefinitionBuilderPart) : void {
		builderParts.push(part);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addBuilderFunction (fc:Function, ...additionalArgs) : void {
		builderParts.push(new FunctionDelegateBuilderPart(fc, additionalArgs));
	}
	
	/**
	 * @inheritDoc
	 */
	public function setDefinitionReplacer (replacer:ObjectDefinitionReplacer) : void {
		if (this.replacer != null) {
			throw new IllegalStateError("Replacer has already been set for " + targetType);
		}
		this.replacer = replacer;
	}
	
	/**
	 * @inheritDoc
	 */
	public function processDefinition (target:ObjectDefinition) : ObjectDefinition {
		applyBuilderParts(target);
		return applyDefinitionReplacer(target);
	}

	private function applyBuilderParts (target:ObjectDefinition) : void {
		for each (var part:ObjectDefinitionBuilderPart in builderParts) {
			part.apply(target);
		}
	}
	
	private function applyDefinitionReplacer (target:ObjectDefinition) : ObjectDefinition {
		if (replacer == null) {
			return target;
		}
		var newDef:ObjectDefinition = replacer.replace(target);
		if (((newDef is SingletonObjectDefinition) && !(target is SingletonObjectDefinition))
				|| ((newDef is DynamicObjectDefinition) && !(target is DynamicObjectDefinition))) {
			throw new IllegalOperationError("Replaced definition '" + newDef 
					+ "' is not of the same type as the original '" + target + "'");		
		}
		return newDef;
	}
}
}

import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.dsl.impl.ObjectDefinitionBuilderPart;

class FunctionDelegateBuilderPart implements ObjectDefinitionBuilderPart {
	
	private var builderFunction:Function;
	private var additionalArgs:Array;
	
	function FunctionDelegateBuilderPart (builderFunction:Function, additionalArgs:Array) {
		this.builderFunction = builderFunction;
		this.additionalArgs = additionalArgs;
	}
	
	public function apply (target:ObjectDefinition) : void {
		var params:Array = additionalArgs.concat();
		params.unshift(target);
		builderFunction.apply(null, params);
	}
	
}


