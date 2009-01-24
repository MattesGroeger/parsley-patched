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

package org.spicefactory.parsley.core {
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class CompositeContextBuilder {
	
	
	private var _registry:ObjectDefinitionRegistry;
	private var _domain:ApplicationDomain;
	
	
	function CompositeContextBuilder (parent:Context = null, domain:ApplicationDomain = null, 
			registry:ObjectDefinitionRegistry = null) {
		_registry = (registry != null) ? registry : new DefaultObjectDefinitionRegistry();
	}
	
	
	public function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}

	public function get domain () : ApplicationDomain {
		return _domain;
	}


	public function build () : Context {
		var df:DefaultContext = new DefaultContext();
		// TODO - handle parent
		df.initialize();
		return df;
	}
	
	
}

}
