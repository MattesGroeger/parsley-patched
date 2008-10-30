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
	
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.xml.ChildConfig;
	
/**
 * A <code>ChildConfig</code> implementation that represents a child node from 
 * a custom configuration namespace.
 */
public class NamespaceChildConfig implements ChildConfig {
	
	
	private var _RequiredInterface:Class;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param RequiredInterface the interface that the configuration instance created
	 * by the <code>createChild</code> method must implement
	 */
	function NamespaceChildConfig (RequiredInterface:Class) {
		_RequiredInterface = RequiredInterface;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get name () : String {
		return "[custom namespace tag]";
	}
	
	/**
	 * @inheritDoc
	 */
	public function isValidCount (count:uint) : Boolean {
		return true;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isSingleton () : Boolean {
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function createChild (context:ApplicationContext, node:XML) : ElementConfig {
		
		var qName:QName = node.name() as QName;
		var namespaceUri:String = qName.uri;
		var tagName:String = qName.localName;
		
		var namespaceList:NamespaceListConfig = context.config.setupConfig.namespacesConfig;
		var namespaceConfig:NamespaceConfig = namespaceList.getNamespaceConfig(namespaceUri);
		if (namespaceConfig == null) {
			throw new ConfigurationError("No custom tag configuration available for namespace: " + namespaceUri);
		}
		if (_RequiredInterface == RootObjectFactoryConfig) {
			return namespaceConfig.getRootObjectFactoryConfig(tagName);
		} else if (_RequiredInterface == NestedObjectFactoryConfig) {
			return namespaceConfig.getNestedObjectFactoryConfig(tagName);
		} else if (_RequiredInterface == ObjectProcessorConfig) {
			return namespaceConfig.getObjectProcessorConfig(tagName);
		} else {
			throw new ConfigurationError("Illegal Interface for namespace children: " + _RequiredInterface);
		}
	}
	
}

}