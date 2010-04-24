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

package org.spicefactory.parsley.core.lifecycle {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.ObjectDefinition;

/**
 * Represents a single managed object, the actual instance alongside with its definition
 * and associated Context.
 * 
 * @author Jens Halm
 */
public interface ManagedObject {
	
	/**
	 * The definition the object was created from or the definition that
	 * was applied to an existing instance.
	 */
	function get definition () : ObjectDefinition;
	
	/**
	 * The actual managed instance.
	 */
	function get instance () : Object;
	
	/**
	 * The Context that managed this object.
	 */
	function get context () : Context;
	
	
}
}
