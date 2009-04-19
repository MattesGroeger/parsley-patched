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

package org.spicefactory.parsley.xml.tag {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.factory.model.ObjectIdReference;
import org.spicefactory.parsley.factory.model.ObjectTypeReference;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ObjectReference {
	
	
	public var idRef:String;
	
	public var typeRef:String;
	
	public var required:Boolean;
	
	
	
	public function resolve (domain:ApplicationDomain) : Object {
		if ((idRef == null && typeRef == null) || (idRef != null && typeRef != null)) {
			throw new IllegalStateError("Exactly one attribute of type-ref or id-ref must be specified");
		}
		return (idRef != null) ? new ObjectIdReference(idRef, required) 
								: new ObjectTypeReference(ClassInfo.forName(typeRef, domain), required);
	}
	
	
}
}
