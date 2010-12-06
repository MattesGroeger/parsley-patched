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

package org.spicefactory.parsley.core.bootstrap.impl {
import org.spicefactory.parsley.core.bootstrap.Service;

/**
 * Default implementation of the Service interface.
 * 
 * @author Jens Halm
 */
public class DefaultService implements Service {
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param serviceInterface the interface all implementations of this service must implement
	 */
	function DefaultService (serviceInterface:Class) {
		_serviceInterface = serviceInterface;
	}
	
	
	private var _parent:Service;
	
	/**
	 * The parent registry to be used to pull additional decorators and the default implementation from.
	 */
	public function set parent (value:Service) : void {
		_parent = value;
	}
	
	
	private var _serviceInterface:Class;
	
	/**
	 * @inheritDoc
	 */
	public function get serviceInterface () : Class {
		return _serviceInterface;
	}
	
	
	private var _decorators:Array = new Array();
	
	/**
	 * @inheritDoc
	 */
	public function get decorators () : Array {
		return (_parent) ? _parent.decorators.concat(_decorators) : _decorators.concat();
	}
	
	
	private var _factory:ServiceFactory;
	
	/**
	 * @inheritDoc
	 */
	public function get factory () : ServiceFactory {
		return (_factory) ? _factory : (_parent) ? _parent.factory : null;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function addDecorator (type:Class, ...params) : void {
		_decorators.push(new ServiceFactory(type, params, serviceInterface));
	}
	
	/**
	 * @inheritDoc
	 */
	public function setImplementation (type:Class, ...params) : void {
		_factory = new ServiceFactory(type, params, serviceInterface);
	}

	/**
	 * @inheritDoc
	 */
	public function newInstance() : Object {
		var service:Object = factory.newInstance();
		for each (var decorator:ServiceFactory in decorators) {
			service = decorator.newInstance(service);
		}
		return service;
	}
	
	
}
}
