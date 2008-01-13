/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.tree {
import org.spicefactory.parsley.context.tree.namespaces.template.nested.ApplyValueChildrenConfig;
import org.spicefactory.parsley.context.tree.values.ValueConfig;

/**
 * Abstract base implementation for all configuration classes that accept a sequence
 * of the standard value tags like <code>&lt;boolean&gt;</code> or <code>&lt;string&gt;</code> as
 * child nodes representing Array elements. Examples are the <code>&lt;init-method&gt;</code>
 * or <code>&lt;constructor-args&gt;</code> tags.
 * 
 * @author Jens Halm
 */
public class AbstractArrayValueHolderConfig			
		extends AbstractValueHolderConfig {
	

	private var _elementConfigs:Array;

	/**
	 * @private
	 */
	function AbstractArrayValueHolderConfig () {
		_elementConfigs = new Array();
	}
	
	/**
	 * Adds a value configuration that represents an Array element.
	 * 
	 * @param config the value configuration to add as an Array element
	 */
	public function addChildConfig (config:ValueConfig) : void {
		_elementConfigs.push(config);
	}
	
	/**
	 * Returns the fully populated Array.
	 * 
	 * @return the fully populated Array
	 */
	protected function getArray () : Array {
		var elements:Array = new Array();
		for each (var config:ValueConfig in _elementConfigs) {
			if (config is ApplyValueChildrenConfig) {
				ApplyValueChildrenConfig(config).fillArray(elements);
			} else {
				elements.push(config.value);
			}
		}
		return elements;
	}
}

}