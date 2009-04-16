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

package org.spicefactory.parsley.factory {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.errors.ContextError;

/**
 * @author Jens Halm
 */
public class DecoratorUtil {
	
	
	public static function getMethod (name:String, definition:ObjectDefinition) : Method {
		var method:Method = definition.type.getMethod(name);
		if (method == null) {
			throw new ContextError("Class " + definition.type.name + " does not contain a method with name " + name);
		}
		return method;
	}
	
	
}
}
