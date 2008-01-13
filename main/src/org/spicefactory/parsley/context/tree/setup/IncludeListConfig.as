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
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the <code>&lt;includes&gt;</code> tag. The parent tag for a sequence of
 * child tags that specify configuration files to include to the currently processed one.
 * 
 * @author Jens Halm
 */
public class IncludeListConfig 
		extends AbstractElementConfig {
	
	
	
	private var _includeConfigs:Array;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("include", IncludeConfig, [], 0);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * Creates a new instance.
	 */
	function IncludeListConfig () {
		_includeConfigs = new Array();
	}
	
	/**
	 * Adds a file to be included to this configuration.
	 * 
	 * @param ic the configuration for a file to be included to this configuration
	 */
	public function addIncludeConfig (ic:IncludeConfig) : void {
		_includeConfigs.push(ic);
	}
	
	
	/**
	 * Processes all included files, adding them to the specified <code>ApplicationContextParser</code>.
	 * 
	 * @param parser the ApplicationContextParser to add the included files to
	 */
	public function process (parser:ApplicationContextParser) : void {
		for each (var inc:IncludeConfig in _includeConfigs) {
			parser.addFile(inc.file);
		}
		_includeConfigs = new Array();
	}
	
	
	
}

}