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

package org.spicefactory.parsley.factory.decorator {
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionHolder;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

/**
 * @author Jens Halm
 */
[Metadata(name="InjectConstructor", types="class")]
public class InjectConstructorDecorator implements ObjectDefinitionDecorator {


	public function decorate (definitionHolder:ObjectDefinitionHolder, registry:ObjectDefinitionRegistry) : void {
		var definition:ObjectDefinition = definitionHolder.processedDefinition;
		for (var i:uint = 0; i < definition.type.getConstructor().parameters.length; i++) {
			definition.constructorArgs.addTypeReference();
		}
	}
	
	
}
}
