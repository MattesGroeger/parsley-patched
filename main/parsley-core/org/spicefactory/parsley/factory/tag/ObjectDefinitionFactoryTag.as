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

package org.spicefactory.parsley.factory.tag {
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionFactory;

/**
 * Represents the root object tag for an object definition in MXML or XML configuration.
 * 
 * @author Jens Halm
 */
public class ObjectDefinitionFactoryTag extends DefaultObjectDefinitionFactory {
	
	
	/**
	 * Creates a new instance.
	 */
	function ObjectDefinitionFactoryTag () {
		super(null); // type will be set via property
	}
	
	
}
}
