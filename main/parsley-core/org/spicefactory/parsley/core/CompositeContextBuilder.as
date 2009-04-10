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
import org.spicefactory.parsley.core.events.ContextBuilderEvent;

import flash.events.EventDispatcher;

import org.spicefactory.parsley.core.impl.ChildContext;
import org.spicefactory.parsley.core.impl.DefaultContext;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;

import flash.system.ApplicationDomain;

/**
 * Dispatched when the builder completed and the context property has been set.
 * 
 * @eventType org.spicefactory.parsley.core.events.ContextBuilderEvent.COMPLETE
 */
[Event(name="complete", type="org.spicefactory.parsley.core.events.ContextBuilderEvent")]

/**
 * @author Jens Halm
 */
public class CompositeContextBuilder extends EventDispatcher {

	
	private var _context:Context;
	private var _parent:Context;
	private var _registry:ObjectDefinitionRegistry;
	
	
	function CompositeContextBuilder (parent:Context = null, domain:ApplicationDomain = null) {
		_parent = parent;
		_registry = new DefaultObjectDefinitionRegistry(domain);
	}
	
	
	public function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}

	public function get parent () : Context {
		return _parent;
	}
	
	public function get context () : Context {
		return _context;
	}

	public function build () : Context {
		var dc:DefaultContext = (parent != null) 
				? new ChildContext(parent, registry) 
				: new DefaultContext(registry);
		dc.initialize();
		_context = dc;
		dispatchEvent(new ContextBuilderEvent(ContextBuilderEvent.COMPLETE));
		return dc;	
	}
	
	
}

}
