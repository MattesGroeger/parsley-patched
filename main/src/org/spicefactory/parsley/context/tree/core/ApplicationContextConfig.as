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
 
package org.spicefactory.parsley.context.tree.core {
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.setup.SetupConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the root <code>&lt;application-context&gt;</code> tag in a Parsley
 * configuration file.
 * 
 * @author Jens Halm
 */
public class ApplicationContextConfig extends AbstractElementConfig {
	
	
	private var _setupConfig:SetupConfig;
	private var _factoryConfig:FactoryConfig;
	private var _context:ApplicationContext;
	
	/**
	 * Creates a new instance.
	 */
	function ApplicationContextConfig () {
		
	}
	

	public function set context (context:ApplicationContext) : void {
		_context = context;
	} 
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("setup", SetupConfig, [], 0, 1);
			ep.addChildNode("factory", FactoryConfig, [], 0, 1);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	
	public function set setupConfig (config:SetupConfig) : void {
		if (_setupConfig == null) {
			_setupConfig = config;
		} else {
			_setupConfig.merge(config);
		}
	}
	
	public function set factoryConfig (config:FactoryConfig) : void {
		if (_factoryConfig == null) {
			_factoryConfig = config;
		} else {
			_factoryConfig.merge(config);
		}
	}
	
	/**
	 * The setup configuration that is processed before any object from the factory
	 * is instantiated.
	 */
	public function get setupConfig () : SetupConfig {
		if (_setupConfig == null) {
			_setupConfig = new SetupConfig();
			_setupConfig.context = _context;
		}
		return _setupConfig;
	}
	
	/**
	 * The configuration of the factory of this ApplicationContext.
	 */
	public function get factoryConfig () : FactoryConfig {
		if (_factoryConfig == null) {
			_factoryConfig = new FactoryConfig();
		}
		return _factoryConfig;
	}
	
	
}

}