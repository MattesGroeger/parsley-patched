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
 
package org.spicefactory.parsley.mvc.impl {
import org.spicefactory.parsley.mvc.Action;

/**
 * Represents a single registered action.
 * 
 * @author Jens Halm
 */
public interface ActionRegistration extends Action {


	/**
	 * Indicates whether the specified object is equal to this one.
	 * 
	 * @param other the object with which to compare
	 * @return true if the specified object is equal to this one 
	 */
	function equals (other:ActionRegistration) : Boolean;

	
}

}
