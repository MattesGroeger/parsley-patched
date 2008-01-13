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
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents all custom configuration namespaces for an <code>ApplicationContext</code>.
 * 
 * @author Jens Halm
 */
public class NamespaceListConfig  
		extends AbstractElementConfig implements ApplicationContextAware {

	
	private var _namespaceConfigs:SimpleMap;
	private var _context:ApplicationContext;
			
			
	private static var _elementProcessor:ElementProcessor;

	/**
	 * @private
	 */	
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("namespace", NamespaceConfig, [], 0);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	
	/**
	 * Creates a new instance.
	 */
	function NamespaceListConfig () {
		_namespaceConfigs = new SimpleMap();
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
	 * Adds a single custom configuration namespace.
	 * 
	 * @param nc the custom configuration namespace to add
	 */
	public function addNamespaceConfig (nc:NamespaceConfig) : void {
		var uri:String = nc.uri;
		if (_namespaceConfigs.containsKey(uri)) {
			throw new ConfigurationError("Duplicate configuration for namespace " + uri);
		}
		_namespaceConfigs.put(uri, nc);
	}
	
	/**
	 * Merges another list of namespace configurations with this one.
	 * Does not allow duplicate namespaces URIs.
	 * 
	 * @param nc the list of namespace configuration to merge with this one
	 */
	public function merge (nc:NamespaceListConfig) : void {
		for each (var ns:NamespaceConfig in nc._namespaceConfigs.values) {
			addNamespaceConfig(ns);
		}
	}
	
	/**
	 * Returns the namespace configuration for the specified namespace URI.
	 * Will delegate to the parent context if no matching configuration is found
	 * in this instance.
	 * 
	 * @return the namespace configuration for the specified namespace URI or null if no such 
	 * configuration exists
	 */
	public function getNamespaceConfig (uri:String) : NamespaceConfig {
		var config:NamespaceConfig = _namespaceConfigs.get(uri);
		if (config == null && _context.parent != null) {
			return _context.parent.config.setupConfig.namespacesConfig.getNamespaceConfig(uri);
		}
		return config;
	}


}

}