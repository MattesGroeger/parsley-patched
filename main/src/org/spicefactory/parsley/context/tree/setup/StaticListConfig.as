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
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;static-initializer&gt;</code> tag.
 * Any static properties that are set by Parsley configuration files will be processed
 * before any object configuration in the factory of
 * the <code>ApplicationContext</code>.
 * 
 * @author Jens Halm
 */
public class StaticListConfig extends AbstractElementConfig implements ApplicationContextAware {
	
	
	private var _staticConfigs:Array;
	private var _context:ApplicationContext;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("static", StaticConfig, [], 0);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}

	/**
	 * Creates a new instance.
	 */
	function StaticListConfig () {
		_staticConfigs = new Array();
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
	 * Adds a single configuration for static properties to this set.
	 * 
	 * @param sc the configuration for static properties to add to this set
	 */
	public function addStaticConfig (sc:StaticConfig) : void {
		_staticConfigs.push(sc);
	}
	
	/**
	 * Merges the content of another static initializer configuration with this one.
	 * 
	 * @param sc the static initializer configuration to merge with this one
	 */	
	public function merge (sc:StaticListConfig) : void {
		_staticConfigs = _staticConfigs.concat(sc._staticConfigs);
	}	
		
	/**
	 * Processes this set of static initializers.
	 * This method will delegate to the individual configurations managed by this set.
	 */
	public function process () : void {
		var destroyCommands:CommandChain = new CommandChain();
		for (var i:Number = 0; i < _staticConfigs.length; i++) {
			var config:StaticConfig = StaticConfig(_staticConfigs[i]);
			config.process(destroyCommands);
		}
		if (!destroyCommands.isEmpty()) {
			_context.addDestroyCommand(destroyCommands);
		}
	}
	
	
}

}