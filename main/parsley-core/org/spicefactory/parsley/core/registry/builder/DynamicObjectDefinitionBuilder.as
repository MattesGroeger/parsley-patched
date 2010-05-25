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

package org.spicefactory.parsley.core.registry.builder {
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectInstantiator;

[Deprecated(replacement="new configuration DSL")]
/**
 * @author Jens Halm
 */
public interface DynamicObjectDefinitionBuilder {
	
	function id (value:String) : DynamicObjectDefinitionBuilder;

	function decorator (value:ObjectDefinitionDecorator) : DynamicObjectDefinitionBuilder;

	function decorators (value:Array) : DynamicObjectDefinitionBuilder;
	
	function instantiator (value:ObjectInstantiator) : DynamicObjectDefinitionBuilder;
	
	function build () : DynamicObjectDefinition;
	
	function buildAndRegister () : DynamicObjectDefinition;
	
}
}
