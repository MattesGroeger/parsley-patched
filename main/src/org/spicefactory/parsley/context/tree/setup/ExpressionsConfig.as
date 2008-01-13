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
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;	

/**
 * Represents the <code>&lt;expressions&gt;</code> tag.
 * 
 * @author Jens Halm
 */
public class ExpressionsConfig extends AbstractElementConfig implements ApplicationContextAware {


	private var _variableResolverConfigs:Array;
	private var _propertyResolverConfigs:Array;
	private var _variableConfigs:Array;
	
	private var _context:ApplicationContext;
	

	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("variable-resolver", VariableResolverConfig, [], 0);
			ep.addChildNode("property-resolver", PropertyResolverConfig, [], 0);
			ep.addChildNode("variable", VariableConfig, [], 0);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}

	
	/**
	 * Creates a new instance.
	 */
	public function ExpressionsConfig () {
		_variableConfigs = new Array();
		_variableResolverConfigs = new Array();
		_propertyResolverConfigs = new Array();
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
	 * Adds a <code>VariableResolver</code> configuration.
	 * 
	 * @param param the <code>VariableResolver</code> configuration to add to this ExpressionConfig
	 */
	public function addVariableResolverConfig (param:VariableResolverConfig) : void {
		_variableResolverConfigs.unshift(param);
	}

	/**
	 * Adds a <code>PropertyResolver</code> configuration.
	 * 
	 * @param param the <code>PropertyResolver</code> configuration to add to this ExpressionConfig
	 */	
	public function addPropertyResolverConfig (param:PropertyResolverConfig) : void {
		_propertyResolverConfigs.unshift(param);
	}
	
	/**
	 * Adds a variable definition.
	 * 
	 * @param param the variable definition to add to this ExpressionConfig
	 */
	public function addVariableConfig (vc:VariableConfig) : void {
		_variableConfigs.push(vc);
	}
		
	/**
	 * Merges the content of another expression configuration with the content of this instance.
	 * 
	 * @param vc the expression configuration to merge with this instance
	 */
	public function merge (vc:ExpressionsConfig) : void {
		_variableResolverConfigs = _variableResolverConfigs.concat(vc._variableResolverConfigs);
		_propertyResolverConfigs = _propertyResolverConfigs.concat(vc._propertyResolverConfigs);
		_variableConfigs = _variableConfigs.concat(vc._variableConfigs);
	}
	
	/**
	 * Processes this expression configuration and populates the <code>expressionContext</code>
	 * property of the <code>ApplicationContext</code>.
	 */
	public function process () : void {
		var expressionContext:ExpressionContext = _context.expressionContext;
		for each (var variableResolver:VariableResolverConfig in _variableResolverConfigs) {
			expressionContext.addVariableResolver(variableResolver.createInstance());
		}
		for each (var propertyResolver:PropertyResolverConfig in _propertyResolverConfigs) {
			expressionContext.addPropertyResolver(propertyResolver.createInstance());
		}
		for each (var variable:VariableConfig in _variableConfigs) {
			expressionContext.setVariable(variable.name, variable.value);
		}
	}
	
	
}

}