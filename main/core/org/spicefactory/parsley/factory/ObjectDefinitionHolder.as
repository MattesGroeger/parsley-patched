/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.factory {

/**
 * @author Jens Halm
 */
public class ObjectDefinitionHolder {
	
	
	private var _processedDefinition:ObjectDefinition;
	private var _targetDefinition:ObjectDefinition;
	
	
	function ObjectDefinitionHolder (definition:ObjectDefinition) {
		_processedDefinition = definition;
		_targetDefinition = definition;
	}

	
	public function get processedDefinition () : ObjectDefinition {
		return _processedDefinition;
	}
	
	public function set processedDefinition (processedDefinition:ObjectDefinition) : void {
		_processedDefinition = processedDefinition;
	}
	
	public function get targetDefinition () : ObjectDefinition {
		return _targetDefinition;
	}
	
	public function set targetDefinition (targetDefinition:ObjectDefinition) : void {
		_targetDefinition = targetDefinition;
	}
	
	
}
}
