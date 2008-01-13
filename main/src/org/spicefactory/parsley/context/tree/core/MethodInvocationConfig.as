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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * The configuration for a single method invocation 
 * - in XML the <code>&lt;init-method&gt;</code> or <code>&lt;destroy-method&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class MethodInvocationConfig  
		extends AbstractMethodConfig implements ObjectProcessorConfig {


	private var _name:String;

	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			addValueConfigs(ep);
			ep.addAttribute("name", StringConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
		
	
	/**
	 * Creates a new instance.
	 */
	function MethodInvocationConfig () {
		super();
	}

	public override function set methodName (name:String) : void {
		_name = name;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function get methodName () : String {
		if (_name != null) {
			return _name;
		} else {
			return getAttributeValue("name");
		}
	}
	
	/**
	 * Processes this configuration, invoking the configured method on the specified instance.
	 * 
	 * @param obj the target instance to invoke the method on
	 * @param ci the type information for the target instance
	 * @param destroyCommands the chain to add commands to that need to be processed when
	 * the ApplicationContext gets destroyed
	 */
	public function process (obj:Object, ci:ClassInfo, destroyCommands:CommandChain) : void {
		invoke(obj);
	}
	
	
	
}

}