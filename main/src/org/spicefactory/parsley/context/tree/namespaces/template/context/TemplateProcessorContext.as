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
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ElementConfig;


/**
 * Manages the stack of currently processed templates. Provides access to the top of
 * the stack
 * 
 * @author Jens Halm
 */
public class TemplateProcessorContext {
	
	
	private static var contextStack:Array = new Array();
	
	
	/**
	 * Pushes the specified contextual information on the stack.
	 * 
	 * @param context the <code>ApplicationContext</code> that belongs to the currently processed element
	 * @param config the configuration of the currently processed element
	 * @param attributes the attributes extracted from the currently processed template client node
	 */
	public static function pushTemplateContext (context:ApplicationContext, config:ElementConfig, 
			attributes:Object) : void {
		contextStack.push(new Context(context, config, attributes));
	}
	
	/**
	 * Pops the contextual information from the top of the stack.
	 */
	public static function popTemplateContext () : void {
		if (contextStack.length == 0) {
			throw new ConfigurationError("Internal error: Attempt to pop empty context stack");
		}
		contextStack.pop();
	}
	
	/**	
	 * Returns the <code>ElementConfig</code> instance from the top of the stack.
	 * 
	 * @return the <code>ElementConfig</code> instance from the top of the stack
	 */
	public static function getActiveConfig () : ElementConfig {
		if (contextStack.length == 0) {
			throw new ConfigurationError("Context stack is empty");
		}
		return Context(contextStack[contextStack.length - 1]).config;
	}
	
	/**
	 * Returns the value for the specified attribute name from the top of the stack.
	 * 
	 * @param name the name of the attribute
	 * @return the value of the attribute from the top of the stack or undefined if no such
	 * attribute exists
	 */
	public static function getAttribute (name:String) : * {
		if (contextStack.length == 0) return undefined;
		return Context(contextStack[contextStack.length - 1]).getAttributeValue(name);
	}



}
}

import org.spicefactory.lib.expr.Expression;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.Attribute;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.xml.AttributeConfig;	

class Context {
	
	private var _context:ApplicationContext;
	public var config:ElementConfig;
	private var _attributes:Object;
	
	function Context (context:ApplicationContext, c:ElementConfig, a:Object) {
		_context = context;
		config = c;
		_attributes = createAttributes(a);
	}
	
	public function getAttributeValue (name:String) : * {
		var attr:Attribute = _attributes[name] as Attribute;
		return (attr == null) ? undefined : attr.getValue();
	}
	
	private function createAttributes (xmlAttributes:Object) : Object {
		var result:Object = new Object();
		for (var attrName:String in xmlAttributes) {
			var config:AttributeConfig = new AttributeConfig(attrName, null, false);
			var expr:Expression = _context.expressionContext.createExpression(xmlAttributes[attrName]);
			result[attrName] = new Attribute(expr, config);
		}
		return result;
	}
	
	
}

