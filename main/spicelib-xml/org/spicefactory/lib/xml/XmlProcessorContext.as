/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.lib.xml {
import flash.system.ApplicationDomain;

import org.spicefactory.lib.expr.ExpressionContext;

/**
 * @author Jens Halm
 */
public class XmlProcessorContext {
	
	
	public static var namingStrategy:NamingStrategy;
	
	private var _expressionContext:ExpressionContext;
	private var _applicationDomain:ApplicationDomain;
	private var _data:Object;
	
	private var _errors:Array = new Array();
	

	function XmlProcessorContext (expressionContext:ExpressionContext = null, domain:ApplicationDomain = null, data:Object = null) {
		_expressionContext = expressionContext;
		_applicationDomain = domain;
		_data = data;
	}

	
	public function get applicationDomain () : ApplicationDomain {
		return _applicationDomain;
	}
	
	public function get expressionContext () : ExpressionContext {
		return _expressionContext;
	}
	
	public function get data () : Object {
		return _data;
	}
	
	public function addError (error:Error) : void {
		_errors.push(error);
	}
	
	public function hasErrors () : Boolean {
		return _errors.length > 0;
	}
	
	public function get errors () : Array {
		return _errors.concat();
	}
	
	
}

}
