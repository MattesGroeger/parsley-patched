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

package org.spicefactory.parsley.core.builder {
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;

import flash.events.ErrorEvent;

/**
 * @author Jens Halm
 */
public class ErrorReporter {
	
	
	private var _errors:Array = new Array();
	
	
	public function addDecoratorError (error:Error, definition:ObjectDefinition, decorator:ObjectDefinitionDecorator) : void {
		_errors.push(error);
	}
	
	public function addDecoratorErrorMessage (message:String, definition:ObjectDefinition, decorator:ObjectDefinitionDecorator) : void {
		_errors.push(message);
	}
	
	public function addFactoryError (error:Error, factory:ObjectDefinitionFactory) : void {
		_errors.push(error);
	}
	
	public function addFactoryErrorMessage (message:String, factory:ObjectDefinitionFactory) : void {
		_errors.push(message);
	}

	public function addBuilderError (error:Error, builder:ObjectDefinitionBuilder) : void {
		_errors.push(error);
	}
	
	public function addBuilderErrorMessage (message:String, builder:ObjectDefinitionBuilder) : void {
		_errors.push(message);
	}
	
	public function addBuilderErrorEvent (event:ErrorEvent, builder:ObjectDefinitionBuilder) : void {
		_errors.push(event);
	}
	
	
	
	public function hasErrors () : Boolean {
		return _errors.length > 0;
	}
	
	public function get errors () : Array {
		return _errors.concat();
	}
	
	
}
}
