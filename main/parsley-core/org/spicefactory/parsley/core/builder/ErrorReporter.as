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
import flash.events.ErrorEvent;

/**
 * @author Jens Halm
 */
public class ErrorReporter {
	
	
	private var _errors:Array = new Array();
	
	
	public function addError (error:Error) : void {
		_errors.push(error);
	}
	
	public function addErrorEvent (event:ErrorEvent) : void {
		_errors.push(event);
	}
	
	public function addErrorMessage (message:String) : void {
		_errors.push(message);
	}
	
	
	public function hasErrors () : Boolean {
		return _errors.length > 0;
	}
	
	public function get errors () : Array {
		return _errors.concat();
	}
	
	
}
}
