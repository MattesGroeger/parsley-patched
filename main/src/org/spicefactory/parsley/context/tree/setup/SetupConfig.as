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
 
package org.spicefactory.parsley.context.tree.setup {
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.localization.LocalizationConfig;
import org.spicefactory.parsley.context.tree.namespaces.NamespaceListConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;setup&gt;</code> tag, the root tag for all the configuration
 * logic that should be processed before any object configuration in the factory of
 * the <code>ApplicationContext</code>.
 * 
 * @param Jens Halm 
 */
public class SetupConfig  extends AbstractElementConfig {
	
	
	private var _includesConfig:IncludeListConfig;
	private var _expresionsConfig:ExpressionsConfig;
	private var _namespacesConfig:NamespaceListConfig;
	private var _staticInitializersConfig:StaticListConfig;
	private var _localizationConfig:LocalizationConfig;
	
	private var _context:ApplicationContext;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("includes", IncludeListConfig, [], 0, 1);
			ep.addChildNode("expressions", ExpressionsConfig, [], 0, 1);
			ep.addChildNode("namespaces", NamespaceListConfig, [], 0, 1);
			ep.addChildNode("static-initializers", StaticListConfig, [], 0, 1);
			ep.addChildNode("localization", LocalizationConfig, [], 0, 1);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	public function set context (context:ApplicationContext) : void {
		_context = context;
	}
	
	/**
	 * @private
	 */
	 public override function parse (node:XML, context:ApplicationContext) : void {
	 	_context = context;
	 	super.parse(node, context);
	 }
	
	/**
	 * The configuration for the list of configuration files to include.
	 */
	public function get includesConfig () : IncludeListConfig {
		if (_includesConfig == null) {
			_includesConfig = new IncludeListConfig();
		}
		return _includesConfig;
	}
	
	/**
	 * The configuration for the expression context. This context is
	 * responsible for processing all variables like <code>${user.name}</code>
	 * that are used in configuration files.
	 */
	public function get expressionsConfig () : ExpressionsConfig {
		return _expresionsConfig;
	}
	
	/**
	 * The configuration for custom configuration namespaces.
	 */
	public function get namespacesConfig () : NamespaceListConfig {
		if (_namespacesConfig == null) {
			_namespacesConfig = new NamespaceListConfig();
			_namespacesConfig.applicationContext = _context;
		}
		return _namespacesConfig;
	}
	
	public function get staticInitializersConfig () : StaticListConfig {
		return _staticInitializersConfig;
	}
	
	/**
	 * The configuration for localization.
	 */
	public function get localizationConfig () : LocalizationConfig {
		return _localizationConfig;
	}
	
	public function set includesConfig (ic:IncludeListConfig) : void {
		_includesConfig = ic;
	}
	
	public function set expressionsConfig (vc:ExpressionsConfig) : void {
		if (_expresionsConfig == null) {
			_expresionsConfig = vc;
		} else {
			_expresionsConfig.merge(vc);
		}
	}
	
	public function set namespacesConfig (nc:NamespaceListConfig) : void {
		if (_namespacesConfig == null) {
			_namespacesConfig = nc;
		} else {
			_namespacesConfig.merge(nc);
		}
	}
	
	public function set staticInitializersConfig (sc:StaticListConfig) : void {
		if (_staticInitializersConfig == null) {
			_staticInitializersConfig = sc;
		} else {
			_staticInitializersConfig.merge(sc);
		}
	}
	
	public function set localizationConfig (ic:LocalizationConfig) : void {
		if (_localizationConfig == null) {
			_localizationConfig = ic;
		} else {
			_localizationConfig.merge(ic);
		}
	}
	
	/**
	 * Merges the content of another setup configuration with this one.
	 * 
	 * @param sc the setup configuration to merge with this one
	 */
	public function merge (sc:SetupConfig) : void {
		if (sc == null) return;
		includesConfig = sc.includesConfig;
		expressionsConfig = sc.expressionsConfig;
		namespacesConfig = sc.namespacesConfig;
		staticInitializersConfig = sc.staticInitializersConfig;
		localizationConfig = sc.localizationConfig;
	}
	
	/**
	 * Processes the configuration after parsing.
	 * Delegates to all configuration artifacts handled by this setup configuration.
	 */
	public function process () : void {
		if (_expresionsConfig != null) _expresionsConfig.process();
		if (_staticInitializersConfig != null) _staticInitializersConfig.process();
		if (_localizationConfig != null) _localizationConfig.process();
	}
	
	
	
}

}