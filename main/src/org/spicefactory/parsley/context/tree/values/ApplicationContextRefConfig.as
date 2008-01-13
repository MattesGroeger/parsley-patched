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

import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
	
/**
 * Represents a reference to the ApplicationContext that created the configured object.
 * - in XML configuration the &lt;application-context-ref&gt; tag. 
 * 
 * @author Jens Halm
 */
public class ApplicationContextRefConfig  
		extends AbstractElementConfig implements ValueConfig, ApplicationContextAware {


	private var _context:ApplicationContext;



	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * Creates a new instance.
	 */
	function ApplicationContextRefConfig () {
		
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
	 * @inheritDoc
	 */	
	public function get value () : * {
		return _context;
	}

	/**
	 * @private
	 */
	public function toString () : String {
		return "ApplicationContext Reference";
	}
	
	
	
}

}