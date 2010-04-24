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

package org.spicefactory.parsley.core.registry.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;

/**
 * Abstract base class for all RootObjectDefinition implementations.
 * 
 * @author Jens Halm
 */
public class AbstractRootObjectDefinition extends AbstractObjectDefinition implements RootObjectDefinition {


	private var _id:String;

	/**
	 * Creates a new instance.
	 * 
	 * @param type the type to create a definition for
	 * @param id the id the object should be registered with
	 */
	function AbstractRootObjectDefinition (type:ClassInfo, id:String) {
		super(type);
		_id = id;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		return _id;
	}

	
}

}
