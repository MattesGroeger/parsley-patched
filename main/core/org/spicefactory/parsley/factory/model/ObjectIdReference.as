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

package org.spicefactory.parsley.factory.model {

/**
 * @author Jens Halm
 */
public class ObjectIdReference {


	private var _id:String;
	private var _required:Boolean;
	
	
	function ObjectIdReference (id:String, required:Boolean = true) {
		_id = id;
		_required = required;
	}

	public function get required () : Boolean {
		return _required;
	}

	public function get id ():String {
		return _id;
	}

	
}

}
