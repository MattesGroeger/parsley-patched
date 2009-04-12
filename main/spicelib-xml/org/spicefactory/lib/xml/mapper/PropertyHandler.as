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

package org.spicefactory.lib.xml.mapper {
import org.spicefactory.lib.reflect.Property;

/**
 * @author Jens Halm
 */
public interface PropertyHandler {
	
	
	/**
	 * The Property the attribute should map to.
	 */
	function get property () : Property;
	
	function get xmlNames () : Array;
	
	function get nodeKind () : String;
	
	
	function toObject (node:XML, parentInstance:Object) : void;

	function toXML (instance:Object, parentElement:XML) : void;
	
	
}
}
