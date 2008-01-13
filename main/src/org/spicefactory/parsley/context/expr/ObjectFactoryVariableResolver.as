/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.expr {
import org.spicefactory.lib.expr.VariableResolver;
import org.spicefactory.parsley.context.ApplicationContext;	

/**
 * VariableResolver implementation that resolves variable names by matching
 * them to ids of objects in an <code>ApplicationContext</code> and then
 * using those object as variable values.
 * 
 * @author Jens Halm
 */
public class ObjectFactoryVariableResolver implements VariableResolver {
	
	
	private var _context:ApplicationContext;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the <code>ApplicationContext</code> to obtain objects from
	 */
	function ObjectFactoryVariableResolver (context:ApplicationContext) {
		_context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function resolveVariable (variableName : String) : * {
		if (_context.containsObject(variableName)) {
			return _context.getObject(variableName);
		} else {
			return undefined;
		}
	}
	
	
	
}

}