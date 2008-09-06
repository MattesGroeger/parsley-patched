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
import flash.utils.Dictionary;

import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.DelegatingNestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.DelegatingRootObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the configuration for a custom tag
 * that acts as an object factory. Such a tag is usually used at places where
 * an <code>&lt;object&gt;</code> tag could also be used.
 * Such a tag is responsible for instantiating the object and possibly providing some
 * initial configuration.
 * 
 * @author Jens Halm
 */
public class ObjectFactoryTagConfig	 
		extends AbstractTagConfig implements ObjectFactoryConfigBuilder {
	
	
	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			_elementProcessor[domain] = createElementProcessor(ObjectFactoryConfig);
		}
		return _elementProcessor[domain];
	}
	

	private function createObjectFactoryConfig () : ObjectFactoryConfig {
		var ofc:Object = type.newInstance([]);
		return ObjectFactoryConfig(ofc);
	}
	
	/**
	 * @inheritDoc
	 */
	public function buildRootObjectFactoryConfig() : RootObjectFactoryConfig {
		return DelegatingRootObjectFactoryConfig.forFactoryConfig(createObjectFactoryConfig());
	}

	/**
	 * @inheritDoc
	 */
	public function buildNestedObjectFactoryConfig() : NestedObjectFactoryConfig {
		return DelegatingNestedObjectFactoryConfig.forFactoryConfig(createObjectFactoryConfig());
	}
	
	
}

}