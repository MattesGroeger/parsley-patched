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

package org.spicefactory.parsley.factory.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.errors.ObjectDefinitionBuilderError;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.model.ManagedArray;
import org.spicefactory.parsley.factory.model.ObjectIdReference;
import org.spicefactory.parsley.factory.model.ObjectTypeReference;
import org.spicefactory.parsley.factory.tag.ArrayTag;
import org.spicefactory.parsley.factory.tag.ObjectReferenceTag;

/**
 * @author Jens Halm
 */
public class RegistryValueResolver {
	
	
	public function resolveValue (value:*, registry:ObjectDefinitionRegistry) : * {
		if (value is ObjectDefinitionFactory) {
			return ObjectDefinitionFactory(value).createNestedDefinition(registry);
		}
		else if (value is ObjectReferenceTag) {
			var objRef:ObjectReferenceTag = value as ObjectReferenceTag;
			if ((objRef.idRef != null && objRef.typeRef != null) || (objRef.idRef == null && objRef.typeRef == null)) {
				throw new ObjectDefinitionBuilderError("Exactly one attribute of either id-ref or type-ref must be specified");
			}
			if (objRef.idRef != null) {
				return new ObjectIdReference(objRef.idRef, objRef.required);
			}
			else {
				return new ObjectTypeReference(ClassInfo.forName(objRef.typeRef, registry.domain), objRef.required);
			}
		}
		else if (value is ArrayTag) {
			var arrayTag:ArrayTag = value as ArrayTag;
			var managedArray:Array = new ManagedArray();
			for (var i:int = 0; i < arrayTag.values.length; i++) {
				managedArray.push(resolveValue(arrayTag.values[i], registry));
			}
			return managedArray;
		}
		else {
			return value;
		}
	} 
	
	public function resolveValues (values:Array, registry:ObjectDefinitionRegistry):void {
		for (var i:int = 0; i < values.length; i++) {
			values[i] = resolveValue(values[i], registry);
		}
	}	


}
}
