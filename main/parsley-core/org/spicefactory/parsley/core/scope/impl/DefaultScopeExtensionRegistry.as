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

package org.spicefactory.parsley.core.scope.impl {
import org.spicefactory.parsley.core.bootstrap.impl.DefaultService;
import org.spicefactory.parsley.core.bootstrap.Service;
import org.spicefactory.parsley.core.scope.ScopeExtensionRegistry;

import flash.utils.Dictionary;

/**
 * Default implementation of the ScopeExtensionRegistry interface.
 * 
 * @author Jens Halm
 */
public class DefaultScopeExtensionRegistry implements ScopeExtensionRegistry {

	
	private var _parent:ScopeExtensionRegistry;
	
	private var types:Dictionary = new Dictionary();
	
	
	/**
	 * @inheritDoc
	 */
	public function forType (type:Class) : Service {
		var service:Service = types[type] as Service;
		if (!service) {
			service = new DefaultService(type);
			types[type] = service;
		}
		return service;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getAll () : Dictionary {
		var services:Dictionary = new Dictionary();
		for (var type:Object in types) {
			if (Service(types[type]).factory) {
				services[type] = types[type];
			}
		}
		if (_parent) {
			var inheritedTypes:Dictionary = _parent.getAll();
			for (var inheritedType:Object in inheritedTypes) {
				if (!types[inheritedType]) {
					services[inheritedType] = inheritedTypes[inheritedType];
				}
				else {
					var child:DefaultService = types[inheritedType];
					child.parent = inheritedTypes[inheritedType];
					if (!services[inheritedType]) {
						services[inheritedType] = inheritedTypes[inheritedType];
					}
				}
			}
		}
		return services;
	}
	
	
	/**
	 * The parent registry to be used to pull additional extensions from.
	 */
	public function set parent (value:ScopeExtensionRegistry) : void {
		_parent = value;	
	}
	
	
}
}
