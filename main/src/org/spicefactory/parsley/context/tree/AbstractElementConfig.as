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
import org.spicefactory.lib.errors.AbstractMethodError;

import flash.system.ApplicationDomain;

import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Abstract base implementation of the <code>ElementConfig</code> interface that delegates
 * XML parsing to an <code>ElementProcessor</code> implementation.
 * 
 * @author Jens Halm
 */
public class AbstractElementConfig 
		extends AbstractAttributeContainer implements ElementConfig {
	
	
	private var _domain:ApplicationDomain;
	
	
	/**
	 * The <code>ApplicationDomain</code> to use to load class definitions. May be null,
	 * in this case <code>ApplicationDomain.currentDomain</code> should be used.
	 */
	protected function get domain () : ApplicationDomain {
		return _domain;
	}	
	
	
	/**
	 * @inheritDoc
	 */
	public function parse (node : XML, context : ApplicationContext) : void {
		_domain = context.applicationDomain;
		var ep:ElementProcessor = getElementProcessor();
		if (ep == null) {
			throw new ConfigurationError("Unable to obtain ElementProcessor");
		}
		ep.parse(node, this, context);
	}
	
	
	/**
	 * Returns the <code>ElementProcessor</code> instance to use for XML parsing.
	 * 
	 * @return the <code>ElementProcessor</code> instance to use for XML parsing
	 */
	protected function getElementProcessor () : ElementProcessor {
		throw new AbstractMethodError();
	}
}

}