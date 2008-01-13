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
 
package org.spicefactory.parsley.context.tree.namespaces.template.context {
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.namespaces.NamespaceConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.TemplateConfig;

/**
 * Context that provides access to the processed template and namespace configuration.
 * 
 * @author Jens Halm
 */
public class TemplateParserContext {
	
	
	private static var _currentContext:TemplateParserContext;
	
	private var _namespaceConfig:NamespaceConfig;
	private var _currentTemplateConfig:TemplateConfig;
	
	
	/**
	 * @private
	 */
	function TemplateParserContext (ns:NamespaceConfig) {
		if (_currentContext != null) {
			throw new ConfigurationError("There is already an active TemplateParserContext for namespace: " + _currentContext.namespaceConfig.uri);
		}
		_namespaceConfig = ns;
	}
	
	/**
	 * Creates a new context instance for the specified namespace configuration.
	 * 
	 * @param ns the currently processed namespace configuration
	 * @return a new <code>TemplateParserContext</code> instance for the specified namespace configuration
	 */
	public static function createNewContext (ns:NamespaceConfig) : TemplateParserContext {
		_currentContext = new TemplateParserContext(ns);
		return _currentContext;
	}
	
	/**
	 * Returns the currently active <code>TemplateParserContext</code>.
	 * 
	 * @return the currently active <code>TemplateParserContext</code> or null if no template
	 * is currently processed.
	 */
	public static function getCurrentContext () : TemplateParserContext {
		return _currentContext;
	}
	
	/**
	 * Clears the active <code>TemplateParserContext</code> instance.
	 */
	public static function clearContext () : void {
		if (_currentContext == null) {
			throw new ConfigurationError("No TemplateParserContext currently active");
		}		
		_currentContext = null;
	}
	
	/**
	 * The currently processed namespace configuration.
	 */
	public function get namespaceConfig () : NamespaceConfig {
		return _namespaceConfig;
	}
	
	public function set templateConfig (value:TemplateConfig) : void {
		_currentTemplateConfig = value;
	}
	/**
	 * The currently processed template configuration.
	 */
	public function get templateConfig () : TemplateConfig {
		return _currentTemplateConfig;
	}



}

}