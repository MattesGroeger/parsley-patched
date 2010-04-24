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

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;

/**
 * Default implementation of the DynamicObjectDefinition interface.
 * 
 * @author Jens Halm
 */
public class DefaultDynamicObjectDefinition extends AbstractRootObjectDefinition implements DynamicObjectDefinition {

	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 * @param id the id the object should be registered with
	 */
	function DefaultDynamicObjectDefinition (type:ClassInfo, id:String) {
		super(type, id);
	}
	

}

}
