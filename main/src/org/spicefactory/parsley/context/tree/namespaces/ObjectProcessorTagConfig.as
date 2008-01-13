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
 
package org.spicefactory.parsley.context.tree.namespaces {

import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.xml.ElementProcessor;
	
/**
 * Represents the configuration for a custom tag
 * that acts as an object processor. Such a tag is usually an immediate child of
 * an <code>&lt;object&gt;</code> tag or a custom tag that represents an object factory.
 * These child tags are then responsible for configuring the object (setting property values,
 * adding listeners, etc.).
 * 
 * @author Jens Halm
 */
public class ObjectProcessorTagConfig  
		extends AbstractTagConfig implements ObjectProcessorConfigBuilder {
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			_elementProcessor = createElementProcessor(ObjectProcessorConfig);
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public function buildObjectProcessorConfig() : ObjectProcessorConfig {
		var opc:Object = type.newInstance([]);
		return ObjectProcessorConfig(opc);
	}
	
	
}

}