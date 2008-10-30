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
 
package org.spicefactory.parsley.context.tree {
import org.spicefactory.lib.expr.Expression;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.xml.AttributeConfig;

/**
 * Represents a single configuration attribute.
 * 
 * @author Jens Halm
 */
public class Attribute {
	
	
	private var _expression:Expression;
	private var _config:AttributeConfig;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param expression the expression to evaluate for the value of this attribute.
	 * @param config the configuration for this attribute.
	 */
	public function Attribute (expression:Expression, config:AttributeConfig) {
		_expression = expression;
		_config = config;
	}
	
	/**
	 * Returns the value of this attribute.
	 * Evaluates the expression and possibly converts the result. If the value is
	 * undefined tries to use a default value. If all attempts to determine the value 
	 * fail and this attribute is configured as required this method throws an Error.
	 * 
	 * @return the value for this attribute
	 */
	public function getValue () : * {
		var value:* = (_expression == null) ? undefined : _expression.value;
		if (value === undefined) {
			if (_config.defaultValue != null) {
				return _config.defaultValue;
			} else {
				if (_config.required) {
					throw new ConfigurationError("Attribute with name '" + _config.name + "' is required");
				} else {
					return undefined;
				}
			}
		} else {
			if (_config.converter == null) {
				return value;
			} else {
				try {
					value = _config.converter.convert(value);
				} catch (e:Error) {
					throw new ConfigurationError("Error converting attribute '" + _config.name + "'", e);
				}
				return value;
			}
		}
	}	
	
}

}