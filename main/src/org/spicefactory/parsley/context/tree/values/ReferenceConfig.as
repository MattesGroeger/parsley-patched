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
 
package org.spicefactory.parsley.context.tree.values {
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;	

/**
 * Represents a reference to another object in the same ApplicationContext 
 * - in XML configuration the &lt;object-ref&gt; tag. 
 * 
 * @author Jens Halm
 */
public class ReferenceConfig  
		extends AbstractElementConfig implements ValueConfig, ApplicationContextAware {


	private var _ref:String;
	private var _context:ApplicationContext;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
		
	
	/**
	 * Creates a new instance.
	 */
	function ReferenceConfig () {
		
	}
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	/**
	 * The name of the referenced object in the ApplicationContext.
	 */
	public function get ref () : String {
		if (_ref != null) {
			return _ref;
		} else {
			return getAttributeValue("id");
		}
	}
	
	public function set ref (value:String) : void {
		_ref = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get value () : * {
		var value:* = _context.getObject(ref);
		if (value == null) {
			throw new ConfigurationError("No object registered with id '" + _ref + "'");
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "Reference to Object '" + _ref + "'";
	}
	
	
}

}