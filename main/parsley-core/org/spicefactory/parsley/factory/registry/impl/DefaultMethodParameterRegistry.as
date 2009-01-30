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

package org.spicefactory.parsley.factory.registry.impl {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.registry.MethodParameterRegistry;

/**
 * @author Jens Halm
 */
public class DefaultMethodParameterRegistry extends AbstractParameterRegistry implements MethodParameterRegistry {


	private var _method:Method;

	
	function DefaultMethodParameterRegistry (method:Method, def:ObjectDefinition) {
		super(method, def);
		_method = method;
	}
	
	
	public function get method () : Method {
		return _method;
	}

	public function addValue (value:*) : MethodParameterRegistry {
		doAddValue(value);
		return this;
	}
	
	public function addIdReference (id:String, required:Boolean = true) : MethodParameterRegistry {
		doAddIdReference(id, required);
		return this;
	}

	public function addTypeReference (required:Boolean = true) : MethodParameterRegistry {
		doAddTypeReference(required);
		return this;
	}

	
}

}