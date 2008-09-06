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
 
package org.spicefactory.parsley.context.tree.values {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.core.AbstractMethodConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents a method used to dynamically resolve parameters of a localized message 
 * - in XML configuration the &lt;param-method&gt; tag. 
 * 
 * @author Jens Halm
 */
public class ParamMethodConfig extends AbstractMethodConfig {


	private var _target:String;
	private var _method:String;


	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			addValueConfigs(ep);
			ep.addAttribute("target", StringConverter.INSTANCE, true);
			ep.addAttribute("method", StringConverter.INSTANCE, true);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	
	
	public override function set methodName (value:String) : void {
		_method = value;
	}
	
	/**
	 * The name of the method to invoke to resolve parameters.
	 * The return type of the method must be Array.
	 */
	public override function get methodName () : String {
		if (_method != null) {
			return _method;
		} else {
			return getAttributeValue("method");
		}
	}
	
	public function set target (value:String) : void {
		_target = value;
	}

	/**
	 * The name of the target instance that the method should be invoked on.
	 */
	public function get target () : String {
		if (_target != null) {
			return _target;
		} else {
			return getAttributeValue("target");
		}
	}
	
	/**
	 * Creates and returns a Command that executes the method represented by this ParamMethodConfig
	 * instance.
	 * 
	 * @return a Command that can be executed to resolve the parameters of a localized message
	 */
	public function createCommand () : Command {
		if (!(target[methodName] is Function)) {
			throw new ConfigurationError("Unable to resolve method '" + methodName + "' for given target object");
		}
		return new Command(target[methodName] as Function, getArray());
	}
	

}

}