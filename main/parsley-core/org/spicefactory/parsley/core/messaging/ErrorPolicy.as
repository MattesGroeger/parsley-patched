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

package org.spicefactory.parsley.core.messaging {

/**
 * @author Jens Halm
 */
public class ErrorPolicy {
	
	
	public static const RETHROW:ErrorPolicy = new ErrorPolicy("rethrow");

	public static const ABORT:ErrorPolicy = new ErrorPolicy("abort");

	public static const IGNORE:ErrorPolicy = new ErrorPolicy("ignore");

	
	private var _key:String;
	
	
	function ErrorPolicy (key:String) {
		_key = key;
	}

	
	public function toSting () : String {
		return _key;
	}
	
	
}
}
