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
 
package org.spicefactory.parsley.context.tree {

/**
 * Abstract base implementation of the <code>AttributeContainer</code> interface.
 * This implementation caches the values for attributes whose expressions have already been evaluated.
 * 
 * @author Jens Halm
 */
public class AbstractAttributeContainer	 
		implements AttributeContainer {
	
	
	private var _attributes:Object;
	
	
	/**
	 * Creates a new instance.
	 */
	function AbstractAttributeContainer () {
		_attributes = new Object();
	}
	
	/**
	 * @inheritDoc
	 */
	public function setAttribute (name : String, attribute : Attribute) : void {
		_attributes[name] = attribute;
	}
	
	/**
	 * Returns the <code>Attribute</code> instance for the specfied name.
	 * 
	 * @param name the name of the attribute
	 * @return the Attribute instance for the specified name or null if no such attribute exists
	 */
	protected function getAttribute (name:String) : Attribute {
		return _attributes[name];
	}
	
	/**
	 * Returns the value for the attribute with the specified name.
	 * 
	 * @param name the name of the attribute
	 * @return the value of the attribute or undefined if no such attribute exists
	 */
	protected function getAttributeValue (name:String) : * {
		var attr:Attribute = getAttribute(name);
		return (attr == null) ? undefined : attr.getValue();
	} 


}

}